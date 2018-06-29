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
import './ITrader.sol';
import './ITraders.sol';

contract Traders is ITraders, Ownable {

  mapping(uint8 => ITrader) public traders; // Mappings of ids of allowed addresses
  mapping(address => bool) public addresses; // Mappings of addresses of allowed addresses

  /// @dev Add a valid trader address. Only owner.
  function addTrader(uint8 protocolId, ITrader trader) public onlyOwner {
    require(protocolId == trader.getProtocol());
    traders[protocolId] = trader;
    addresses[trader] = true;
  }

  /// @dev Remove a trader address. Only owner.
  function removeTrader(uint8 protocolId) public onlyOwner {
    delete addresses[traders[protocolId]];
    delete traders[protocolId];
  }

  /// @dev Get trader by protocolId.
  function getTrader(uint8 protocolId) public view returns(ITrader) {
    return traders[protocolId];
  }

  /// @dev Check if an address is a valid trader.
  function isValidTraderAddress(address addr) public view returns(bool) {
    return addresses[addr];
  }
}
