// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/StakingPool.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor() ERC20("Mock", "MCK") {
        _mint(msg.sender, 1e24);
    }
}

contract StakingTest is Test {
    MockToken token;
    StakingPool staking;
    address user = address(0x1234);

    function setUp() public {
        token = new MockToken();
        staking = new StakingPool(address(token));
        token.transfer(user, 1e21);
    }

    function testStakeIncreasesBalance() public {
        vm.prank(user);
        token.approve(address(staking), 1e18);
        vm.prank(user);
        staking.stake(1e18);
        assertEq(staking.balances(user), 1e18);
    }

    function testWithdrawDecreasesBalance() public {
        vm.startPrank(user);
        token.approve(address(staking), 1e18);
        staking.stake(1e18);
        staking.withdraw(1e18);
        vm.stopPrank();
        assertEq(staking.balances(user), 0);
    }
}
