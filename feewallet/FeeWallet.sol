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

pragma solidity ^0.4.19;

import '../helpers/Ownable.sol';
import '../helpers/SafeMath.sol';
import '../helpers/Members.sol';
import './IFeeWallet.sol';


contract FeeWallet is IFeeWallet, Ownable, Members {

  address public serviceAccount; // Address of service account
  uint public servicePercentage; // Percentage times (1 ether)
  uint public affiliatePercentage; // Percentage times (1 ether)

  mapping (address => uint) public pendingWithdrawals; // Balances

  function FeeWallet(
    address _serviceAccount,
    uint _servicePercentage,
    uint _affiliatePercentage) public
  {
    serviceAccount = _serviceAccount;
    servicePercentage = _servicePercentage;
    affiliatePercentage = _affiliatePercentage;
  }

  /// @dev Set the new service account. Only owner.
  function changeServiceAccount(address _serviceAccount) public onlyOwner {
    serviceAccount = _serviceAccount;
  }

  /// @dev Set the service percentage. Only owner.
  function changeServicePercentage(uint _servicePercentage) public onlyOwner {
    servicePercentage = _servicePercentage;
  }

  /// @dev Set the affiliate percentage. Only owner.
  function changeAffiliatePercentage(uint _affiliatePercentage) public onlyOwner {
    affiliatePercentage = _affiliatePercentage;
  }

  /// @dev Calculates the service fee for a specific amount. Only owner.
  function getFee(uint amount) public view returns(uint)  {
    return SafeMath.safeMul(amount, servicePercentage) / (1 ether);
  }

  /// @dev Calculates the affiliate amount for a specific amount. Only owner.
  function getAffiliateAmount(uint amount) public view returns(uint)  {
    return SafeMath.safeMul(amount, affiliatePercentage) / (1 ether);
  }

  /// @dev Collects fees according to last payment receivedi. Only valid smart contracts.
  function collect(
    address _affiliate) public payable onlyMembers
  {
    if(_affiliate == address(0))
      pendingWithdrawals[serviceAccount] += msg.value;
    else {
      uint affiliateAmount = getAffiliateAmount(msg.value);
      pendingWithdrawals[_affiliate] += affiliateAmount;
      pendingWithdrawals[serviceAccount] += SafeMath.safeSub(msg.value, affiliateAmount);
    }
  }

  /// @dev Withdraw.
  function withdraw() public {
    uint amount = pendingWithdrawals[msg.sender];
    pendingWithdrawals[msg.sender] = 0;
    msg.sender.transfer(amount);
  }
}
