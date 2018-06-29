pragma solidity ^0.4.19;

/*
 * Members
 *
 * Base contract with a list of members.
 */

import './Ownable.sol';

contract Members is Ownable {

  mapping(address => bool) public members; // Mappings of addresses of allowed addresses

  modifier onlyMembers() {
    require(isValidMember(msg.sender));
    _;
  }

  /// @dev Check if an address is a valid member.
  function isValidMember(address _member) public view returns(bool) {
    return members[_member];
  }

  /// @dev Add a valid member address. Only owner.
  function addMember(address _member) public onlyOwner {
    members[_member] = true;
  }

  /// @dev Remove a member address. Only owner.
  function removeMember(address _member) public onlyOwner {
    delete members[_member];
  }
}
