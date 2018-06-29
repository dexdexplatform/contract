/*

  Copyright 2018 Dexdex.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.4.21;

import '../helpers/Ownable.sol';
import '../helpers/SafeMath.sol';
import '../helpers/BytesToTypes.sol';
import '../tradeables/ITradeable.sol';
import '../traders/ITraders.sol';
import '../feewallet/IFeeWallet.sol';

contract DexdexERC20 is Ownable, BytesToTypes {
  string constant public VERSION = '2.0.0';

  ITraders public traders; // Smart contract that hold the list of valid traders
  IFeeWallet public feeWallet; // Smart contract that hold the fees collected
  bool public tradingEnabled; // Switch to enable or disable the contract

  event Sell(
    address account,
    address destinationAddr,
    address traedeable,
    uint volume,
    uint volumeEth,
    uint volumeEffective,
    uint volumeEthEffective
  );
  event Buy(
    address account,
    address destinationAddr,
    address traedeable,
    uint volume,
    uint volumeEth,
    uint volumeEffective,
    uint volumeEthEffective
  );


  function DexdexERC20(ITraders _traders, IFeeWallet _feeWallet) public {
    traders = _traders;
    feeWallet = _feeWallet;
    tradingEnabled = true;
  }

  /// @dev Only accepts payment from smart contract traders.
  function() public payable {
  //  require(traders.isValidTraderAddress(msg.sender));
  }

  /// @dev Setter for feeWallet smart contract (Only owner)
  function changeFeeWallet(IFeeWallet _feeWallet) public onlyOwner {
    feeWallet = _feeWallet;
  }

  /// @dev Setter for traders smart contract (Only owner)
  function changeTraders(ITraders _traders) public onlyOwner {
    traders = _traders;
  }

  /// @dev Enable/Disable trading with smart contract (Only owner)
  function changeTradingEnabled(bool enabled) public onlyOwner {
    tradingEnabled = enabled;
  }

  /// @dev Buy a token.
  function buy(
    ITradeable tradeable,
    uint volume,
    bytes ordersData,
    address destinationAddr,
    address affiliate
  ) external payable
  {

    require(tradingEnabled);

    // Execute the trade (at most fullfilling volume)
    trade(
      false,
      tradeable,
      volume,
      ordersData,
      affiliate
    );

    // Since our balance before trade was 0. What we bought is our current balance.
    uint volumeEffective = tradeable.balanceOf(this);

    // We make sure that something was traded
    require(volumeEffective > 0);

    // Used ethers are: balance_before - balance_after.
    // And since before call balance=0; then balance_before = msg.value
    uint volumeEthEffective = SafeMath.safeSub(msg.value, address(this).balance);

    // IMPORTANT: Check that: effective_price <= agreed_price (guarantee a good deal for the buyer)
    require(
      SafeMath.safeDiv(volumeEthEffective, volumeEffective) <=
      SafeMath.safeDiv(msg.value, volume)
    );

    // Return remaining ethers
    if(address(this).balance > 0) {
      destinationAddr.transfer(address(this).balance);
    }

    // Send the tokens
    transferTradeable(tradeable, destinationAddr, volumeEffective);

    emit Buy(msg.sender, destinationAddr, tradeable, volume, msg.value, volumeEffective, volumeEthEffective);
  }

  /// @dev sell a token.
  function sell(
    ITradeable tradeable,
    uint volume,
    uint volumeEth,
    bytes ordersData,
    address destinationAddr,
    address affiliate
  ) external
  {
    require(tradingEnabled);

    // We transfer to ouselves the user's trading volume, to operate on it
    // note: Our balance is 0 before this
    require(tradeable.transferFrom(msg.sender, this, volume));

    // Execute the trade (at most fullfilling volume)
    trade(
      true,
      tradeable,
      volume,
      ordersData,
      affiliate
    );

    // Check how much we traded. Our balance = volume - tradedVolume
    // then: tradedVolume = volume - balance
    uint volumeEffective = SafeMath.safeSub(volume, tradeable.balanceOf(this));

    // We make sure that something was traded
    require(volumeEffective > 0);

    // Collects service fee
    uint volumeEthEffective = collectSellFee(affiliate);

    // IMPORTANT: Check that: effective_price >= agreed_price (guarantee a good deal for the seller)
    require(
      SafeMath.safeDiv(volumeEthEffective, volumeEffective) >=
      SafeMath.safeDiv(volumeEth, volume)
    );

    // Return remaining volume
    if (volumeEffective < volume) {
     transferTradeable(tradeable, destinationAddr, SafeMath.safeSub(volume, volumeEffective));
    }

    // Send ethers obtained
    destinationAddr.transfer(volumeEthEffective);

    emit Sell(msg.sender, destinationAddr, tradeable, volume, volumeEth, volumeEffective, volumeEthEffective);
  }


  /// @dev Trade buy or sell orders.
  function trade(
    bool isSell,
    ITradeable tradeable,
    uint volume,
    bytes ordersData,
    address affiliate
  ) internal
  {
    uint remainingVolume = volume;
    uint offset = ordersData.length;

    while(offset > 0 && remainingVolume > 0) {
      //Get the trader
      uint8 protocolId = bytesToUint8(offset, ordersData);
      ITrader trader = traders.getTrader(protocolId);
      require(trader != address(0));

      //Get the order data
      uint dataLength = trader.getDataLength();
      offset = SafeMath.safeSub(offset, dataLength);
      bytes memory orderData = slice(ordersData, offset, dataLength);

      //Fill order
      remainingVolume = fillOrder(
         isSell,
         tradeable,
         trader,
         remainingVolume,
         orderData,
         affiliate
      );
    }
  }

  /// @dev Fills a buy order.
  function fillOrder(
    bool isSell,
    ITradeable tradeable,
    ITrader trader,
    uint remaining,
    bytes memory orderData,
    address affiliate
    ) internal returns(uint)
  {

    //Checks that there is enoughh amount to execute the trade
    uint volume;
    uint volumeEth;
    (volume, volumeEth) = trader.getFillVolumes(
      isSell,
      orderData,
      remaining,
      address(this).balance
    );

    if(volume > 0) {

      if(isSell) {
        //Approve available amount of token to trader
        require(tradeable.approve(trader, volume));
      } else {
        //Collects service fee
        //TODO: transfer fees after all iteration
        volumeEth = collectBuyFee(volumeEth, affiliate);
        address(trader).transfer(volumeEth);
      }

      //Call trader to trade orders
      trader.trade(
        isSell,
        orderData,
        volume,
        volumeEth
      );

    }

    return SafeMath.safeSub(remaining, volume);
  }

  /// @dev Transfer tradeables to user account.
  function transferTradeable(ITradeable tradeable, address account, uint amount) internal {
    require(tradeable.transfer(account, amount));
  }

  // @dev Collect service/affiliate fee for a buy
  function collectBuyFee(uint ethers, address affiliate) internal returns(uint) {
    uint remaining;
    uint fee = feeWallet.getFee(ethers);
    //If there is enough remaining to pay fee, it substract from the balance
    if(SafeMath.safeSub(address(this).balance, ethers) >= fee)
      remaining = ethers;
    else
      remaining = SafeMath.safeSub(SafeMath.safeSub(ethers, address(this).balance), fee);
    feeWallet.collect.value(fee)(affiliate);
    return remaining;
  }

  // @dev Collect service/affiliate fee for a sell
  function collectSellFee(address affiliate) internal returns(uint) {
    uint fee = feeWallet.getFee(address(this).balance);
    feeWallet.collect.value(fee)(affiliate);
    return address(this).balance;
  }

}
