//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";
contract FundFundMe is Script {

    uint256 constant SEND_VALUE = 0.01 ether;
    function  fundFundMe(address mostRecentDeplyed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeplyed)).fund{value:SEND_VALUE}();
        vm.stopBroadcast();
        
    }
    function run() external{
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundFundMe(mostRecentDeployed);
    }
}


contract WithdrawFundMe is Script {
     function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe balance!");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        withdrawFundMe(mostRecentlyDeployed);
    }
}