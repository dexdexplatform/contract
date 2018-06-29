pragma solidity ^0.4.19;

import '../IERC20Token.sol';

contract IWETH is IERC20Token {

    /// @dev Buys tokens with Ether, exchanging them 1:1.
    function deposit()
        public
        payable;

    /// @dev Sells tokens in exchange for Ether, exchanging them 1:1.
    /// @param amount Number of tokens to sell.
    function withdraw(uint amount)
        public;
}
