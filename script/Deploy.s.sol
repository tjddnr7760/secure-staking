// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/StakingPool.sol";
import "../test/Staking.t.sol";

contract DeployScript is Script {
    function run() public {
        vm.startBroadcast();
        MockToken token = new MockToken();
        StakingPool pool = new StakingPool(address(token));
        vm.stopBroadcast();
    }
}
