// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract StakingPool is ReentrancyGuard {
    IERC20 public immutable stakingToken;
    mapping(address => uint256) public balances;

    constructor(address _stakingToken) {
        stakingToken = IERC20(_stakingToken);
    }

    function stake(uint256 amount) external {
        require(amount > 0, "zero amount");
        balances[msg.sender] += amount;
        bool ok = stakingToken.transferFrom(msg.sender, address(this), amount);
        require(ok, "transferFrom failed");
    }

    function withdraw(uint256 amount) external nonReentrant {
        require(amount <= balances[msg.sender], "insufficient");
        balances[msg.sender] -= amount;
        bool ok = stakingToken.transfer(msg.sender, amount);
        require(ok, "transfer failed");
    }

    function claimRewards() external view returns (uint256) {
        // TODO: reward calculation 구현 예정
        return 0;
    }
}
