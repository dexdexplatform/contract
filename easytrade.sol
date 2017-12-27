pragma solidity 0.4.19;

/*

  Copyright 2017 EasyTrade.

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

contract Token {
    
    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint balance) {}
    
    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint _value) public returns (bool success) {}

    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {}

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint _value) public returns (bool success) {}
    
    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint remaining) {}
}

library SafeMath {
    
    function safeMul(uint a, uint b) internal constant returns (uint256) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint a, uint b) internal constant returns (uint256) {
        uint c = a / b;
        return c;
    }

    function safeSub(uint a, uint b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal constant returns (uint256) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }

    function min256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a < b ? a : b;
    }
}

contract EtherToken is Token {

    /// @dev Buys tokens with Ether, exchanging them 1:1.
    function deposit()
        public
        payable
    {}

    /// @dev Sells tokens in exchange for Ether, exchanging them 1:1.
    /// @param amount Number of tokens to sell.
    function withdraw(uint amount)
        public
    {}
}

contract Exchange {

    /// @dev Fills the input order.
    /// @param orderAddresses Array of order's maker, taker, makerToken, takerToken, and feeRecipient.
    /// @param orderValues Array of order's makerTokenAmount, takerTokenAmount, makerFee, takerFee, expirationTimestampInSec, and salt.
    /// @param fillTakerTokenAmount Desired amount of takerToken to fill.
    /// @param shouldThrowOnInsufficientBalanceOrAllowance Test if transfer will fail before attempting.
    /// @param v ECDSA signature parameter v.
    /// @param r ECDSA signature parameters r.
    /// @param s ECDSA signature parameters s.
    /// @return Total amount of takerToken filled in trade.
    function fillOrder(
          address[5] orderAddresses,
          uint[6] orderValues,
          uint fillTakerTokenAmount,
          bool shouldThrowOnInsufficientBalanceOrAllowance,
          uint8 v,
          bytes32 r,
          bytes32 s)
          public
          returns (uint filledTakerTokenAmount)
    {}

    /*
    * Constant public functions
    */
    
    /// @dev Calculates Keccak-256 hash of order with specified parameters.
    /// @param orderAddresses Array of order's maker, taker, makerToken, takerToken, and feeRecipient.
    /// @param orderValues Array of order's makerTokenAmount, takerTokenAmount, makerFee, takerFee, expirationTimestampInSec, and salt.
    /// @return Keccak-256 hash of order.
    function getOrderHash(address[5] orderAddresses, uint[6] orderValues)
        public
        constant
        returns (bytes32)
    {}
    
     
    /// @dev Calculates the sum of values already filled and cancelled for a given order.
    /// @param orderHash The Keccak-256 hash of the given order.
    /// @return Sum of values already filled and cancelled.
    function getUnavailableTakerTokenAmount(bytes32 orderHash)
        public
        constant
        returns (uint)
    {}
}

contract EtherDelta {
  address public feeAccount; //the account that will receive fees
  uint public feeTake; //percentage times (1 ether)
  
  function deposit() public payable {}

  function withdraw(uint amount) public {}

  function depositToken(address token, uint amount) public {}

  function withdrawToken(address token, uint amount) public {}

  function trade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount) public {}

  function availableVolume(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s) constant returns(uint) {}
}

library EtherDeltaTrader {

  address constant public ETHERDELTA_ADDR = 0x2937a786b0738cca385be085fb24964a0f003bbe; // EtherDelta contract address
  
  /// @dev Gets the address of EtherDelta contract
  /// @return Address of EtherDelta Contract.
  function getEtherDeltaAddresss() internal returns(address) {
      return ETHERDELTA_ADDR;
  }
   
  /// @dev Fills a sell order in EtherDelta.
  /// @param orderAddresses Array of order's maker, makerToken, takerToken.
  /// @param orderValues Array of order's makerTokenAmount, takerTokenAmount, expires and nonce.
  /// @param exchangeFee Fee percentage of the exchange.
  /// @param fillTakerTokenAmount Desired amount of takerToken to fill.
  /// @param v ECDSA signature parameter v.
  /// @param r ECDSA signature parameters r.
  /// @param s ECDSA signature parameters s.
  /// @return Total amount of takerToken filled in trade
  function fillSellOrder(
    address[5] orderAddresses,
    uint[6] orderValues,
    uint exchangeFee,
    uint fillTakerTokenAmount,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal returns(uint) {
    
    //Deposit ethers in EtherDelta
    deposit(fillTakerTokenAmount);
    
    uint amountToTrade;
    uint fee;
      
    //Substract EtherDelta fee
    (amountToTrade, fee) = substractFee(exchangeFee, fillTakerTokenAmount);
    
    //Fill EtherDelta Order
    trade(
      orderAddresses,
      orderValues, 
      amountToTrade,
      v, 
      r, 
      s
    );
    
    //Withdraw token from EtherDelta
    withdrawToken(orderAddresses[1], getPartialAmount(orderValues[0], orderValues[1], amountToTrade));
    
    //Returns the amount of token obtained
    return getPartialAmount(orderValues[0], orderValues[1], amountToTrade);
 
  }
  
  /// @dev Fills a buy order in EtherDelta.
  /// @param orderAddresses Array of order's maker, makerToken, takerToken.
  /// @param orderValues Array of order's makerTokenAmount, takerTokenAmount, expires and nonce.
  /// @param exchangeFee Fee percentage of the exchange.
  /// @param fillTakerTokenAmount Desired amount of takerToken to fill.
  /// @param v ECDSA signature parameter v.
  /// @param r ECDSA signature parameters r.
  /// @param s ECDSA signature parameters s.
  /// @return Total amount of ethers filled in trade
  function fillBuyOrder(
    address[5] orderAddresses,
    uint[6] orderValues,
    uint exchangeFee,
    uint fillTakerTokenAmount,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal returns(uint) {
    
    //Deposit tokens in EtherDelta
    depositToken(orderAddresses[2], fillTakerTokenAmount);
    
    uint amountToTrade;
    uint fee;
      
    //Substract EtherDelta fee
    (amountToTrade, fee) = substractFee(exchangeFee, fillTakerTokenAmount);

    //Fill EtherDelta Order
    trade(
      orderAddresses,
      orderValues, 
      amountToTrade,
      v, 
      r, 
      s
    );
    
    //Withdraw ethers obtained from EtherDelta
    withdraw(getPartialAmount(orderValues[0], orderValues[1], amountToTrade));
    
    //Returns the amount of ethers obtained
    return getPartialAmount(orderValues[0], orderValues[1], amountToTrade);
  }
  
  /// @dev Trade an EtherDelta order.
  /// @param orderAddresses Array of order's maker, makerToken, takerToken.
  /// @param orderValues Array of order's makerTokenAmount, takerTokenAmount, expires and nonce.
  /// @param amountToTrade Desired amount of takerToken to fill.
  /// @param v ECDSA signature parameter v.
  /// @param r ECDSA signature parameters r.
  /// @param s ECDSA signature parameters s.
  function trade(
    address[5] orderAddresses,
    uint[6] orderValues,
    uint amountToTrade,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal {
      
     //Fill EtherDelta Order
     EtherDelta(ETHERDELTA_ADDR).trade(
      orderAddresses[2], 
      orderValues[1], 
      orderAddresses[1], 
      orderValues[0], 
      orderValues[2], 
      orderValues[3], 
      orderAddresses[0], 
      v, 
      r, 
      s, 
      amountToTrade
    );
  }
  
  /// @dev Get the available amount of an EtherDelta order.
  /// @param orderAddresses Array of address arrays containing individual order addresses.
  /// @param orderValues Array of uint arrays containing individual order values.
  /// @param exchangeFee Fee percentage of the exchange.
  /// @param v Array ECDSA signature v parameters.
  /// @param r Array of ECDSA signature r parameters.
  /// @param s Array of ECDSA signature s parameters.
  /// @return Available amount of the order.
  function getAvailableAmount(
    address[5] orderAddresses,
    uint[6] orderValues,
    uint exchangeFee,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal returns(uint) {
      
    //Fill EtherDelta Order
    uint availableVolume = EtherDelta(ETHERDELTA_ADDR).availableVolume(
      orderAddresses[2], 
      orderValues[1], 
      orderAddresses[1], 
      orderValues[0], 
      orderValues[2], 
      orderValues[3], 
      orderAddresses[0], 
      v, 
      r, 
      s
    );
    
    //AvailableVolume adds the fee percentage (X - X * fee)
    return getPartialAmount(availableVolume, SafeMath.safeSub(1 ether, exchangeFee), 1 ether);
  }
  
  /// @dev Substracts the take fee from EtherDelta.
  /// @param amount Amount to substract EtherDelta fee
  /// @return Amount minus the EtherDelta fee.
  function substractFee(uint feePercentage, uint amount) constant internal returns(uint, uint) {
    uint fee = getPartialAmount(amount, 1 ether, feePercentage);
    return (SafeMath.safeSub(amount, fee), fee);
  }
  
  /// @dev Deposit ethers to EtherDelta.
  /// @param amount Amount of ethers to deposit in EtherDelta
  function deposit(uint amount) internal {
    EtherDelta(ETHERDELTA_ADDR).deposit.value(amount)();
  }
  
  /// @dev Deposit tokens to EtherDelta.
  /// @param token Address of token to deposit in EtherDelta
  /// @param amount Amount of tokens to deposit in EtherDelta
  function depositToken(address token, uint amount) internal {
    Token(token).approve(ETHERDELTA_ADDR, amount);
    EtherDelta(ETHERDELTA_ADDR).depositToken(token, amount);
  }
  
  /// @dev Withdraw ethers from EtherDelta
  /// @param amount Amount of ethers to withdraw from EtherDelta
  function withdraw(uint amount) internal { 
    EtherDelta(ETHERDELTA_ADDR).withdraw(amount);
  }
   
  /// @dev Withdraw tokens from EtherDelta.
  /// @param token Address of token to withdraw from EtherDelta
  /// @param amount Amount of tokens to withdraw from EtherDelta
  function withdrawToken(address token, uint amount) internal { 
    EtherDelta(ETHERDELTA_ADDR).withdrawToken(token, amount);
  }
  
  
  /// @dev Calculates partial value given a numerator and denominator.
  /// @param numerator Numerator.
  /// @param denominator Denominator.
  /// @param target Value to calculate partial of.
  /// @return Partial value of target.
  function getPartialAmount(uint numerator, uint denominator, uint target)
    public
    constant
    returns (uint)
  {
    return SafeMath.safeDiv(SafeMath.safeMul(numerator, target), denominator);
  }

}

library ZrxTrader {
    
  uint16 constant public EXTERNAL_QUERY_GAS_LIMIT = 4999;    // Changes to state require at least 5000 gas

  address constant public ZRX_EXCHANGE_ADDR = 0x968e0c1839dd79ea06593d7050e95ffe830e54b3; // 0x Exchange contract address
  address constant public TOKEN_TRANSFER_PROXY_ADDR = 0xc9cd4a0d0c8277ce95fc87994b1f21b86f5345ea; // TokenTransferProxy contract address
  address constant public WETH_ADDR = 0x7b9489b4f1396fb41869e98b5d9f5dc1f746f051; // Wrapped ether address (WETH)
  address constant public ZRX_TOKEN_ADDR = 0x37f25aa38b1f115520827567d076cc19ea307cfb;
  
  /// @dev Gets the address of the Wrapped Ether contract
  /// @return Address of Weth Contract.
  function getWethAddress() internal returns(address) {
      return WETH_ADDR;
  }
  
  /// @dev Fills a sell order in 0x.
  /// @param orderAddresses Array of order's maker, taker, makerToken, takerToken, and feeRecipient.
  /// @param orderValues Array of order's makerTokenAmount, takerTokenAmount, makerFee, takerFee, expirationTimestampInSec, and salt.
  /// @param fillTakerTokenAmount Desired amount of takerToken to fill.
  /// @param v ECDSA signature parameter v.
  /// @param r ECDSA signature parameters r.
  /// @param s ECDSA signature parameters s.
  /// @return Total amount of takerToken filled in trade.
  function fillSellOrder(
    address[5] orderAddresses,
    uint[6] orderValues,
    uint fillTakerTokenAmount,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal returns(uint) 
  {
     
    // Wrap ETH to WETH
    depositWeth(fillTakerTokenAmount);
    
    // Allow 0x Transfer Token Proxy to transfer WETH
    aproveToken(WETH_ADDR, fillTakerTokenAmount);
    
    //Allow ZRX Transfer Token Proxy to transfer the token for fees
    aproveToken(ZRX_TOKEN_ADDR, getPartialAmount(fillTakerTokenAmount, orderValues[1], orderValues[3]));
    
    uint ethersSpent = Exchange(ZRX_EXCHANGE_ADDR).fillOrder(
      orderAddresses,
      orderValues,
      fillTakerTokenAmount,
      true,
      v,
      r,
      s
    );
    
    // Fill 0x order
    return getPartialAmount(orderValues[0], orderValues[1], ethersSpent);
    
  }
  
  /// @dev Fills a buy order in 0x.
  /// @param orderAddresses Array of order's maker, taker, makerToken, takerToken, and feeRecipient.
  /// @param orderValues Array of order's makerTokenAmount, takerTokenAmount, makerFee, takerFee, expirationTimestampInSec, and salt.
  /// @param fillTakerTokenAmount Desired amount of takerToken to fill.
  /// @param v ECDSA signature parameter v.
  /// @param r ECDSA signature parameters r.
  /// @param s ECDSA signature parameters s.
  /// @return Total amount of takerToken filled in trade.
  function fillBuyOrder(
    address[5] orderAddresses,
    uint[6] orderValues,
    uint fillTakerTokenAmount,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal returns(uint) 
  {
    
    //Allow 0x Transfer Token Proxy to transfer the token
    aproveToken(orderAddresses[3], fillTakerTokenAmount);
    
    //Allow ZRX Transfer Token Proxy to transfer the token for fees
    aproveToken(ZRX_TOKEN_ADDR, getPartialAmount(fillTakerTokenAmount, orderValues[1], orderValues[3]));
    
    // Fill 0x order
    uint tokensSold = Exchange(ZRX_EXCHANGE_ADDR).fillOrder(
      orderAddresses,
      orderValues,
      fillTakerTokenAmount,
      true,
      v,
      r,
      s
    );
    
    uint ethersObtained = getPartialAmount(orderValues[0], orderValues[1], tokensSold);
    
    // Unwrap WETH to ETH
    withdrawWeth(ethersObtained);
    
    return ethersObtained;
  }
  
  /// @dev Get the available amount of a 0x order.
  /// @param orderAddresses Array of address arrays containing individual order addresses.
  /// @param orderValues Array of uint arrays containing individual order values.
  /// @param v Array ECDSA signature v parameters.
  /// @param r Array of ECDSA signature r parameters.
  /// @param s Array of ECDSA signature s parameters.
  /// @return Available amount of a 0x order.
  function getAvailableAmount(
    address[5] orderAddresses,
    uint[6] orderValues,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal returns(uint) {
        
      bytes32 orderHash = Exchange(ZRX_EXCHANGE_ADDR).getOrderHash(orderAddresses, orderValues);
      
      uint unAvailable = Exchange(ZRX_EXCHANGE_ADDR).getUnavailableTakerTokenAmount(orderHash);
  
      //Gets the available amount acoording to 0x contract substracting takerTokenAmount with unavailable takerTokenAmount
      uint availableByContract = SafeMath.safeSub(orderValues[1], unAvailable);
      
      //Gets the available amount according of the maker token balance
      uint availableByBalance =getBalance(orderAddresses[2], orderAddresses[0]);
      
      //Gets the available amount according how much allowance of the token the maker has
      uint availableByAllowance = getAllowance(orderAddresses[2], orderAddresses[0]);
    
      //Get the available amount according to how much ZRX fee the maker can pay 
      uint zrxAmount = getAllowance(ZRX_TOKEN_ADDR, orderAddresses[0]);
      uint availableByZRX = getPartialAmount(zrxAmount, orderValues[2], orderValues[0]);
      
      //Returns the min value of all available results
      return SafeMath.min256(SafeMath.min256(SafeMath.min256(availableByContract, availableByBalance), availableByAllowance), availableByZRX);
  }
    
  /// @dev Deposit WETH
  /// @param amount Amount of ether to wrap.
  function depositWeth(uint amount) internal {
    EtherToken(WETH_ADDR).deposit.value(amount)();
  }
  
  /// @dev Approve tokens to be transfered by 0x Token Transfer Proxy
  /// @param token Address of token to approve.
  /// @param amount Amount of tokens to approve.
  function aproveToken(address token, uint amount) internal {
    Token(token).approve(TOKEN_TRANSFER_PROXY_ADDR, amount);
  }
  
  /// @dev Withdraw WETH
  /// @param amount Amount of ether to unwrap.
  function withdrawWeth(uint amount) internal { 
    EtherToken(WETH_ADDR).withdraw(amount);
  }
  
  /// @dev Calculates partial value given a numerator and denominator.
  /// @param numerator Numerator.
  /// @param denominator Denominator.
  /// @param target Value to calculate partial of.
  /// @return Partial value of target.
  function getPartialAmount(uint numerator, uint denominator, uint target) internal constant returns (uint)
  {
    return SafeMath.safeDiv(SafeMath.safeMul(numerator, target), denominator);
  }

  /// @dev Get token balance of an address.
  /// @param token Address of token.
  /// @param owner Address of owner.
  /// @return Token balance of owner.
  function getBalance(address token, address owner) internal constant returns (uint)
  {
    return Token(token).balanceOf.gas(EXTERNAL_QUERY_GAS_LIMIT)(owner); // Limit gas to prevent reentrancy
  }

  /// @dev Get allowance of token given to TokenTransferProxy by an address.
  /// @param token Address of token.
  /// @param owner Address of owner.
  /// @return Allowance of token given to TokenTransferProxy by owner.
  function getAllowance(address token, address owner) internal constant returns (uint)
  {
    return Token(token).allowance.gas(EXTERNAL_QUERY_GAS_LIMIT)(owner, TOKEN_TRANSFER_PROXY_ADDR); // Limit gas to prevent reentrancy
  }
  
 
}

contract EasyTrade {
    
  string constant public VERSION = "1.0.0";

  address public admin; // Admin address
  address public executor; // Account with permission to execute trades
  address public feeAccount; // Account that will receive the fee
  uint public serviceFee; // Percentage times (1 ether)
  uint public collectedFee = 0; // Total of fees accumulated
 
  struct Request {
    uint ethers; 
    uint tokens; 
    address depositAccount;
    address refundAccount;
  }

  mapping (address => mapping (address => Request)) public buys; 
  mapping (address => mapping (address => Request)) public sells; 
  
  event CreateBuyOrder(address account, address token, uint tokens, uint ethers, address depositAccount, address refundAccount);
  event CreateSellOrder(address account, address token, uint tokens, uint ethers, address depositAccount, address refundAccount);
  event CancelBuyOrder(address account, address token, uint amountGive);
  event CancelSellOrder(address account, address token, uint amountGive);
  event FillSellOrder(address account, address token, uint tokensSold, uint ethersObtained);
  event FillBuyOrder(address account, address token, uint tokensObtained, uint ethersSpent);
  
  modifier onlyAdmin() {
    require(msg.sender == admin);
    _;
  }
  
  modifier onlyExecutor() {
    require(msg.sender == executor);
    _;
  }
  
  modifier onlyFeeAccount() {
    require(msg.sender == feeAccount);
    _;
  }
 
  function EasyTrade(
    address admin_,
    address executor_,
    address feeAccount_,
    uint serviceFee_) 
  {
    admin = admin_;
    executor = executor_;
    feeAccount = feeAccount_;
    serviceFee = serviceFee_;
  } 
    
  /// @dev For exchange contracts that send ethers back.
  function() public payable { 
      //Only accepts payments from 0x Wrapped Ether or EtherDelta
      require(msg.sender == ZrxTrader.getWethAddress() || msg.sender == EtherDeltaTrader.getEtherDeltaAddresss());
  }

  /// @dev Set the new admin. Only admin can set the new admin.
  /// @param admin_ Address of the new admin.
  function changeAdmin(address admin_) public onlyAdmin {
    admin = admin_;
  }
  
  /// @dev Set the new admin. Only admin can set the new executor.
  /// @param executor_ Address of the account with permissions to execute.
  function changeExecutor(address executor_) public onlyAdmin {
    executor = executor_;
  }
  
  /// @dev Set the new fee account. Only admin can set the new fee account.
  /// @param feeAccount_ Address of the new fee account.
  function changeFeeAccount(address feeAccount_) public onlyAdmin {
    feeAccount = feeAccount_;
  }

  /// @dev Set the service fee. Only admin can set the new fee. Service fee can only be reduced, never increased
  /// @param serviceFee_ Percentage times (1 ether).
  function changeFeePercentage(uint serviceFee_) public onlyAdmin {
    require(serviceFee_ < serviceFee);
    serviceFee = serviceFee_;
  }
  
  /// @dev Creates or updates an order to sell a token. 
  /// @notice Needs first to call Token(tokend_address).approve(this, tokens_) so the contract can trade the tokens.
  /// @param token_ Address of the token to buy.
  /// @param tokens_ Amount of the token to sell.
  /// @param ethers_ Amount of ethers to get.
  /// @param depositAccount_ Address to where transfer the ethers obtained.
  /// @param refundAccount_ Address to where return the tokens not sold.
  function createSellOrder(
    address token_, 
    uint tokens_, 
    uint ethers_,
    address depositAccount_,
    address refundAccount_
  ) public
  {
    //There should not be a previous sell order
    require(sells[token_][msg.sender].tokens == 0);
    
    //Make sure tokens have been allowed to transfer and sell
    require(Token(token_).allowance(msg.sender, this) >= tokens_);
    
    //Saves the amount of ethers to give and the amount of tokens to get
    sells[token_][msg.sender] = Request({
      tokens: SafeMath.safeAdd(sells[token_][msg.sender].tokens, tokens_),
      ethers: ethers_,
      depositAccount: depositAccount_,
      refundAccount: refundAccount_
    });
    
    CreateSellOrder(msg.sender, token_, tokens_, ethers_, depositAccount_, refundAccount_);
  }
  
  /// @dev Creates or updates an order to buy a token.
  /// @param token_ Address of the token to buy.
  /// @param tokens_ Amount of the token to buy.
  /// @param depositAccount_ Address to where transfer the tokens obtained.
  /// @param refundAccount_ Address to where return the ethers not spent.
  function createBuyOrder(
    address token_, 
    uint tokens_,
    address depositAccount_,
    address refundAccount_
  ) public payable 
  {
     
    //There should not be a previous buy order
    require(buys[token_][msg.sender].ethers == 0);
      
    //Saves the amount of ethers to give and the amount of tokens to get
    buys[token_][msg.sender] = Request({
      ethers: SafeMath.safeAdd(buys[token_][msg.sender].ethers, msg.value),
      tokens: tokens_,
      depositAccount: depositAccount_,
      refundAccount: refundAccount_
    });
    
    CreateBuyOrder(msg.sender, token_, tokens_, msg.value, depositAccount_, refundAccount_);
  }
  
  /// @dev Fills sell orders by synchronously executing exchange buy orders.
  /// @param account Address of the account of the sell order.
  /// @param token Address of the token of the sell order.
  /// @param isEtherDelta Array of booleans with true if the order is from EtherDelta, false if it is from 0x.
  /// @param orderAddresses Array of address arrays containing individual order addresses.
  /// @param orderValues Array of uint arrays containing individual order values.
  /// @param exchangeFees Array of exchange fee percentages to fill in orders.
  /// @param v Array ECDSA signature v parameters.
  /// @param r Array of ECDSA signature r parameters.
  /// @param s Array of ECDSA signature s parameters.
  function executeSellRequest(
    address account,
    address token,
    bool[] isEtherDelta,
    address[5][] orderAddresses,
    uint[6][] orderValues,
    uint[] exchangeFees,
    uint8[] v,
    bytes32[] r,
    bytes32[] s
  ) public onlyExecutor
  {
    
    Request sell = sells[token][account];
    uint ethersTotal = sell.ethers;
    uint tokensTotal = sell.tokens;
    uint ethersObtained;
    uint tokensSold;
    
    //Transfer tokens to contract so it can sell them.
    require(Token(token).transferFrom(account, this, sell.tokens));
    
    (ethersObtained, tokensSold) = fillOrdersForSellRequest(
      tokensTotal,
      isEtherDelta,
      orderAddresses,
      orderValues,
      exchangeFees,
      v,
      r,
      s
    );
    
    //Check that the price of what was sold is not smaller than the min agreed
    require(SafeMath.safeDiv(ethersTotal, tokensTotal) <= SafeMath.safeDiv(ethersObtained, tokensSold));
    
    //Substracts the tokens sold
    sell.tokens = SafeMath.safeSub(tokensTotal, tokensSold);
    
    //Return tokens not sold 
    closeSellOrder(token, account);
    
    //Send the ethersObtained
    transfer(sell.depositAccount, ethersObtained);
    
    FillSellOrder(account, token, tokensSold, ethersObtained);
  }
  
  /// @dev Fills a sell order by synchronously executing exchange buy orders.
  /// @param tokensTotal Total amount of tokens to sell.
  /// @param isEtherDelta Array of booleans with true if the order is from EtherDelta, false if it is from 0x.
  /// @param orderAddresses Array of address arrays containing individual order addresses.
  /// @param orderValues Array of uint arrays containing individual order values.
  /// @param exchangeFees Array of exchange fee percentages to fill in orders.
  /// @param v Array ECDSA signature v parameters.
  /// @param r Array of ECDSA signature r parameters.
  /// @param s Array of ECDSA signature s parameters.
  /// @return Total of ethers obtained.
  function fillOrdersForSellRequest(
    uint tokensTotal,
    bool[] isEtherDelta,
    address[5][] orderAddresses,
    uint[6][] orderValues,
    uint[] exchangeFees,
    uint8[] v,
    bytes32[] r,
    bytes32[] s
  ) internal returns(uint, uint)
  {
    uint totalEthersObtained = 0;
    uint tokensRemaining = tokensTotal;
    
    for (uint i = 0; i < orderAddresses.length; i++) {
   
      (totalEthersObtained, tokensRemaining) = fillOrderForSellRequest(
         totalEthersObtained,
         tokensRemaining,
         isEtherDelta[i],
         orderAddresses[i],
         orderValues[i],
         exchangeFees[i],
         v[i],
         r[i],
         s[i]
      );

    }
    
    //Substracts service fee
    uint fee = SafeMath.safeMul(totalEthersObtained, serviceFee) / (1 ether);
    totalEthersObtained = collectServiceFee(fee, totalEthersObtained);
    
    //Returns ethers obtained
    return (totalEthersObtained, SafeMath.safeSub(tokensTotal, tokensRemaining));
  }
  
  function fillOrderForSellRequest(
    uint totalEthersObtained,
    uint initialTokensRemaining,
    bool isEtherDelta,
    address[5] orderAddresses,
    uint[6] orderValues,
    uint exchangeFee,
    uint8 v,
    bytes32 r,
    bytes32 s
    ) internal returns(uint, uint)
  {
    uint ethersObtained = 0;
    uint tokensRemaining = initialTokensRemaining;
    
    //Exchange fees should not be higher than 1% (in Wei)
    require(exchangeFee < 10000000000000000);
    
    //Checks that there is enoughh amount to execute the trade
    uint fillAmount = getFillAmount(
      tokensRemaining,
      isEtherDelta,
      orderAddresses,
      orderValues,
      exchangeFee,
      v,
      r,
      s
    );
    
    if(fillAmount > 0) {
          
      //Substracts the amount to execute
      tokensRemaining = SafeMath.safeSub(tokensRemaining, fillAmount);
    
      if(isEtherDelta) {
        //Executes EtherDelta buy order and returns the amount of ethers obtained, fullfill all or returns zero
        ethersObtained = EtherDeltaTrader.fillBuyOrder(
          orderAddresses,
          orderValues,
          exchangeFee,
          fillAmount,
          v,
          r,
          s
        );    
      } 
      else {
        //Executes 0x buy order and returns the amount of ethers obtained, fullfill all or returns zero
        ethersObtained = ZrxTrader.fillBuyOrder(
          orderAddresses,
          orderValues,
          fillAmount,
          v,
          r,
          s
        );
        
        //If 0x, exchangeFee is collected by the contract to buy externally ZrxTrader
        uint fee = SafeMath.safeMul(ethersObtained, exchangeFee) / (1 ether);
        ethersObtained = collectServiceFee(fee, ethersObtained);
    
      }
    }
         
    //Adds the amount of ethers obtained and tokens remaining
    return (SafeMath.safeAdd(totalEthersObtained, ethersObtained), ethersObtained==0? initialTokensRemaining: tokensRemaining);
   
  }
  
  /// @dev Fills a buy orders by synchronously executing exchange sell orders.
  /// @param account Address of the account of the buy order.
  /// @param token Address of the token of the buy order.
  /// @param isEtherDelta Array of booleans with true if the order is from EtherDelta, false if it is from 0x.
  /// @param orderAddresses Array of address arrays containing individual order addresses.
  /// @param orderValues Array of uint arrays containing individual order values.
  /// @param exchangeFees Array of exchange fee percentages to fill in orders.
  /// @param v Array ECDSA signature v parameters.
  /// @param r Array of ECDSA signature r parameters.
  /// @param s Array of ECDSA signature s parameters.
  function executeBuyRequest(
    address account,
    address token,
    bool[] isEtherDelta,
    address[5][] orderAddresses,
    uint[6][] orderValues,
    uint[] exchangeFees,
    uint8[] v,
    bytes32[] r,
    bytes32[] s
  ) public onlyExecutor
  {
    
    Request buy = buys[token][account];
    uint ethersTotal = buy.ethers;
    uint tokensTotal = buy.tokens;
    uint tokensObtained;
    uint ethersSpent;
    
    (tokensObtained, ethersSpent) = fillOrdersForBuyRequest(
      ethersTotal,
      isEtherDelta,
      orderAddresses,
      orderValues,
      exchangeFees,
      v,
      r,
      s
    );
    
    //Check that the price of what was sold is not smaller than the min agreed
    require(SafeMath.safeDiv(ethersTotal, tokensTotal) >= SafeMath.safeDiv(ethersSpent, tokensObtained));

    //Substracts the ethers spent
    buy.ethers = SafeMath.safeSub(ethersTotal, ethersSpent);
   
    //Return tokens not sold 
    closeBuyOrder(token, account);
   
    //Send the ethersObtained
    transferToken(token, buy.depositAccount, tokensObtained);
   
    FillBuyOrder(account, token, tokensObtained, ethersSpent);
  }
  
  
  /// @dev Fills a buy order by synchronously executing exchange sell orders.
  /// @param ethersTotal Total amount of ethers to spend.
  /// @param isEtherDelta Array of booleans with true if the order is from EtherDelta, false if it is from 0x.
  /// @param orderAddresses Array of address arrays containing individual order addresses.
  /// @param orderValues Array of uint arrays containing individual order values.
  /// @param exchangeFees Array of exchange fees to fill in orders.
  /// @param v Array ECDSA signature v parameters.
  /// @param r Array of ECDSA signature r parameters.
  /// @param s Array of ECDSA signature s parameters.
  /// @return Total of tokens obtained.
  function fillOrdersForBuyRequest(
    uint ethersTotal,
    bool[] isEtherDelta,
    address[5][] orderAddresses,
    uint[6][] orderValues,
    uint[] exchangeFees,
    uint8[] v,
    bytes32[] r,
    bytes32[] s
  ) internal returns(uint, uint)
  {
    uint totalTokensObtained = 0;
    uint ethersRemaining = ethersTotal;
    for (uint i = 0; i < orderAddresses.length; i++) {
    
      if(ethersRemaining > 0) {
        (totalTokensObtained, ethersRemaining) = fillOrderForBuyRequest(
          totalTokensObtained,
          ethersRemaining,
          isEtherDelta[i],
          orderAddresses[i],
          orderValues[i],
          exchangeFees[i],
          v[i],
          r[i],
          s[i]
        );
      }
    
    }
    
    //Returns total of tokens obtained
    return (totalTokensObtained, SafeMath.safeSub(ethersTotal, ethersRemaining));
  }
  
  
  function fillOrderForBuyRequest(
    uint totalTokensObtained,
    uint initialEthersRemaining,
    bool isEtherDelta,
    address[5] orderAddresses,
    uint[6] orderValues,
    uint exchangeFee,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal returns(uint, uint)
  {
    uint tokensObtained = 0;
    uint ethersRemaining = initialEthersRemaining;
       
    //Exchange fees should not be higher than 1% (in Wei)
    require(exchangeFee < 10000000000000000);
     
    //Checks that there is enoughh amount to execute the trade
    uint fillAmount = getFillAmount(
      ethersRemaining,
      isEtherDelta,
      orderAddresses,
      orderValues,
      exchangeFee,
      v,
      r,
      s
    );
   
    if(fillAmount > 0) {
     
      //Substracts the amount to execute
      ethersRemaining = SafeMath.safeSub(ethersRemaining, fillAmount);
      
      //Substract service fee
      (fillAmount, ethersRemaining) = substractFee(serviceFee, fillAmount, ethersRemaining);
         
      if(isEtherDelta) {
        //Executes EtherDelta order, fee is paid directly to EtherDelta, fullfill all or returns zero
        tokensObtained = EtherDeltaTrader.fillSellOrder(
          orderAddresses,
          orderValues,
          exchangeFee,
          fillAmount,
          v,
          r,
          s
        );
      
      } 
      else {
          
        //If 0x, exchangeFee is collected by the contract to buy externally ZrxTrader, fullfill all or returns zero
        (fillAmount, ethersRemaining) = substractFee(exchangeFee, fillAmount, ethersRemaining);
        
        //Executes 0x order
        tokensObtained = ZrxTrader.fillSellOrder(
          orderAddresses,
          orderValues,
          fillAmount,
          v,
          r,
          s
        );
      }
    }
        
    //Returns total of tokens obtained and ethers remaining
    return (SafeMath.safeAdd(totalTokensObtained, tokensObtained), tokensObtained==0? initialEthersRemaining: ethersRemaining);
  }
  
  
  /// @dev Get the amount to fill in the order.
  /// @param amount Remaining amount of the order.
  /// @param isEtherDelta True if the order is from EtherDelta, false if it is from 0x.
  /// @param orderAddresses Array of address arrays containing individual order addresses.
  /// @param orderValues Array of uint arrays containing individual order values.
  /// @param v Array ECDSA signature v parameters.
  /// @param r Array of ECDSA signature r parameters.
  /// @param s Array of ECDSA signature s parameters.
  /// @return Min amount between the remaining and the order available.
  function getFillAmount(
    uint amount,
    bool isEtherDelta,
    address[5] orderAddresses,
    uint[6] orderValues,
    uint exchangeFee,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal returns(uint) 
  {
    uint availableAmount;
    if(isEtherDelta) {
      availableAmount = EtherDeltaTrader.getAvailableAmount(
        orderAddresses,
        orderValues,
        exchangeFee,
        v,
        r,
        s
      );    
    } 
    else {
      availableAmount = ZrxTrader.getAvailableAmount(
        orderAddresses,
        orderValues,
        v,
        r,
        s
      );
    }
     
    return SafeMath.min256(amount, availableAmount);
  }
  
  /// @dev Substracts the service from the remaining amount if enough, if not from the amount to fill the order.
  /// @param feePercentage Fee Percentage
  /// @param fillAmount Amount to fill the order
  /// @param ethersRemaining Remaining amount of ethers for other orders
  /// @return Amount to fill the order and remainin amount
  function substractFee(
    uint feePercentage,
    uint fillAmount,
    uint ethersRemaining
  ) internal returns(uint, uint) 
  {       
      uint fee = SafeMath.safeMul(fillAmount, feePercentage) / (1 ether);
      //If there is enough remaining to pay fee, it substracts the fee from the remaining
      if(ethersRemaining >= fee)
         ethersRemaining = collectServiceFee(fee, ethersRemaining);
      else {
         fillAmount = collectServiceFee(fee, SafeMath.safeAdd(fillAmount, ethersRemaining));
         ethersRemaining = 0;
      }
      return (fillAmount, ethersRemaining);
  }
  
  /// @dev Substracts the service fee in ethers.
  /// @param fee Service fee in ethers
  /// @param amount Amount to substract service fee
  /// @return Amount minus service fee.
  function collectServiceFee(uint fee, uint amount) internal returns(uint) {
    collectedFee = SafeMath.safeAdd(collectedFee, fee);
    return SafeMath.safeSub(amount, fee);
  }
  
  /// @dev Transfer ethers to user account.
  /// @param account User address where to send ethers.
  /// @param amount Amount of ethers to send.
  function transfer(address account, uint amount) internal {
    require(account.send(amount));
  }
    
  /// @dev Transfer token to user account.
  /// @param token Address of token to transfer.
  /// @param account User address where to transfer tokens.
  /// @param amount Amount of tokens to transfer.
  function transferToken(address token, address account, uint amount) internal {
    require(Token(token).transfer(account, amount));
  }
  
  /// @dev Cancel a buy 
  /// @param token Address of token to buy.
  /// @param account Address of account that created the buy order.
  function cancelBuyOrder(address token, address account) public {
    require(msg.sender == admin || msg.sender == account);
    require(buys[token][account].ethers > 0);
    uint amount = closeBuyOrder(token, account);
    CancelBuyOrder(account, token, amount);
  } 
  
  /// @dev Cancel a sell order
  /// @param token Address of token to sell.
  /// @param account Address of account that created the sell order.
  function cancelSellOrder(address token, address account) public {
    require(msg.sender == admin || msg.sender == account);
    require(sells[token][account].tokens > 0);
    uint amount = closeSellOrder(token, account);
    CancelSellOrder(account, token, amount);
    
  }
  
  /// @dev Cancel buy order.
  /// @param token Address of token to buy.
  /// @param account Address of account that created the buy order.
  /// @return Amount cancelled.
  function closeBuyOrder(address token, address account) internal returns(uint) {
    Request buy = buys[token][account];
    uint remaining = buy.ethers;
    buy.ethers = 0;
    buy.tokens = 0;
    if(remaining > 0)
     require(buy.refundAccount.call.value(remaining)());
    return remaining;
  } 
  
  /// @dev Cancel sell order.
  /// @param token Address of token to sell.
  /// @param account Address of account that created the sell order.
  /// @return Amount cancelled.
  function closeSellOrder(address token, address account) internal returns(uint) {
    Request sell = sells[token][account];
    uint remaining = sell.tokens;
    sell.ethers = 0;
    sell.tokens = 0;
    if(remaining > 0)
      require(Token(token).transferFrom(account, account, remaining));
    return remaining;
  }
   
  /// @dev Withdraw collected service fees. Only by fee account.
  /// @param amount Amount to withdraw
  function withdrawFees(uint amount) public onlyFeeAccount {
    require(collectedFee >= amount);
    collectedFee = SafeMath.safeSub(collectedFee, amount);
    require(feeAccount.send(amount));
  }
}
