// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import { Test, console } from "../../lib/forge-std/src/Test.sol";
import { FundMe } from "../../src/FundMe.sol";
import { DeployFundMe } from "../../script/DeployFundMe.s.sol";
import { FundFundMe, WithdrawFundMe } from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    address USER = makeAddr("user");
    FundMe fundMe;
    uint constant STARTING_BALANCE = 10 ether;
    uint constant SEND_VALUE = 0.1 ether;
    uint constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFund() public {
        uint256 preUserBalance = address(USER).balance;
        
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        uint256 afterUserBalance = address(USER).balance;
        assertEq(afterUserBalance + SEND_VALUE, preUserBalance);
    }

    // function testUserCanFundInteractions() public {
    //     uint256 preUserBalance = address(USER).balance;
        
    //     FundFundMe fundFundMe = new FundFundMe();
    //     vm.prank(USER);
    //     fundFundMe.fundFundMe(address(fundMe));

    //     uint256 afterUserBalance = address(USER).balance;
    //     assertEq(afterUserBalance + SEND_VALUE, preUserBalance);
    // }

    function testUserCanWithdrawInteractions() public {
        uint256 preOwnerBalance = address(fundMe.i_owner()).balance;
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint256 afterOwnerBalance = address(fundMe.i_owner()).balance;
        assert(address(fundMe).balance == 0);
        assertEq(preOwnerBalance + SEND_VALUE, afterOwnerBalance);
    }
}