//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    FundMe public fundMe;
    address USER =makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER,STARTING_BALANCE);
    }

    function testMinimumDollarisFive() public {
        assertEq(fundMe.MINIMUM_USD(),5e18);
    }
        
    function test() public { 
        assertEq(fundMe.getOwner(),msg.sender);
    }

    function testFundFailWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }
    function testDatastructures() public {
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        uint256 amountFunded =fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded,SEND_VALUE);

    }
    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder,USER);

    }
    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        _;

    }

    function testOnlyOwnerCanWidthraw() public{
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();

        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();

    }
    function testWithDrawWithASingleOwner() public funded{
        //Assign

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Action
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance,0);
        assertEq(startingFundMeBalance + startingOwnerBalance,endingOwnerBalance);



    }

    function testWithDrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;
        for (
            uint160 i = startingFunderIndex;
            i < numberOfFunders + startingFunderIndex;
            i++
        ) {
            // we get hoax from stdcheats
            // prank + deal
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
        assert(
            (numberOfFunders + 1) * SEND_VALUE ==
                fundMe.getOwner().balance - startingOwnerBalance
        );
    }

}
