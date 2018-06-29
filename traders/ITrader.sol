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

contract ITrader {

  function getDataLength(
  ) public pure returns (uint256);

  function getProtocol(
  ) public pure returns (uint8);

  function getAvailableVolume(
    bytes orderData
  ) public view returns(uint);

  function isExpired(
    bytes orderData
  ) public view returns (bool); 

  function trade(
    bool isSell,
    bytes orderData,
    uint volume,
    uint volumeEth
  ) public;
  
  function getFillVolumes(
    bool isSell,
    bytes orderData,
    uint volume,
    uint volumeEth
  ) public view returns(uint, uint);

}
