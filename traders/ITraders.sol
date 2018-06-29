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

import './ITrader.sol';

contract ITraders {

  /// @dev Add a valid trader address. Only owner.
  function addTrader(uint8 id, ITrader trader) public;

  /// @dev Remove a trader address. Only owner.
  function removeTrader(uint8 id) public;

  /// @dev Get trader by id.
  function getTrader(uint8 id) public view returns(ITrader);

  /// @dev Check if an address is a valid trader.
  function isValidTraderAddress(address addr) public view returns(bool);

}
