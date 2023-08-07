// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {Adeno} from "../src/Adeno.sol";
import {console} from "forge-std/console.sol";

contract AdenoTest is Test {
    Adeno public adenoToken;
    address treasury = vm.addr(0x1);
    address otherContract1 = vm.addr(0x2);
    address otherContract2 = vm.addr(0x3);
    address user = vm.addr(0x4);

    uint256 private MAX_SUPPLY = 2625000000e18;
    uint256 private TREASURY_BAL = 10e18;

    function setUp() public {
        adenoToken = new Adeno(MAX_SUPPLY);
    }

    function testOwner() public {
        assertEq(adenoToken.owner(), address(this));
    }

    function testTokenName() public {
        assertEq(adenoToken.name(), "Adeno");
    }

    function testTokenSymbol() public {
        assertEq(adenoToken.symbol(), "ADE");
    }

    function testMaxSupply() public {
        assertEq(adenoToken.maxSupply(), MAX_SUPPLY);
    }

    function testOwnerWhitelisted() public {
        assertEq(adenoToken.whitelist(address(this)), true);
    }

    function testMint() public {
        adenoToken.mint(treasury, TREASURY_BAL);
        assertEq(adenoToken.balanceOf(treasury), TREASURY_BAL);
    }

    function testFailExceedsMintSupply() public {
        adenoToken.mint(address(this), MAX_SUPPLY + 1);
    }

    function testAddToWhitelist() public {
        address[] memory whiteListAddr = new address[](2);
        whiteListAddr[0] = otherContract1;
        whiteListAddr[1] = otherContract2;

        adenoToken.addToWhitelist(whiteListAddr);

        assertEq(adenoToken.whitelist(otherContract1), true);
        assertEq(adenoToken.whitelist(otherContract2), true);
    }

    function testFailAddToWhitelist() public {
        vm.startPrank(user);
        address[] memory whiteListAddr = new address[](2);
        whiteListAddr[0] = otherContract1;
        whiteListAddr[1] = otherContract2;

        adenoToken.addToWhitelist(whiteListAddr);
        vm.stopPrank();
    }

    function testRemoveFromWhitelist() public {
        address[] memory whiteListAddr = new address[](2);
        whiteListAddr[0] = otherContract1;
        whiteListAddr[1] = otherContract2;

        adenoToken.addToWhitelist(whiteListAddr);

        assertEq(adenoToken.whitelist(otherContract1), true);
        assertEq(adenoToken.whitelist(otherContract2), true);

        adenoToken.removeFromWhitelist(whiteListAddr);

        assertEq(adenoToken.whitelist(otherContract1), false);
        assertEq(adenoToken.whitelist(otherContract2), false);
    }

    function testFailRemoveFromWhitelist() public {
        vm.startPrank(user);
        address[] memory whiteListAddr = new address[](2);
        whiteListAddr[0] = otherContract1;
        whiteListAddr[1] = otherContract2;

        adenoToken.removeFromWhitelist(whiteListAddr);
        vm.stopPrank();
    }

    function testPause() public {
        address user2 = vm.addr(0x6);
        adenoToken.mint(user, 200e18);
        hoax(user);
        adenoToken.transfer(user2, 10e18);
        hoax(user);
        adenoToken.approve(user2, 50e18);
        assertEq(adenoToken.balanceOf(user), 190e18);
        assertEq(adenoToken.balanceOf(user2), 10e18);
        assertEq(adenoToken.allowance(user, user2), 50e18);
        hoax(user2);
        adenoToken.transferFrom(user, treasury, 10e18);
        assertEq(adenoToken.balanceOf(user), 180e18);
        assertEq(adenoToken.allowance(user, user2), 40e18);
        hoax(user);
        adenoToken.approve(user2, 70e18);
        assertEq(adenoToken.allowance(user, user2), 70e18);
        adenoToken.pause();
        vm.expectRevert("Pausable: paused");
        adenoToken.mint(user, 200e18);
        vm.expectRevert("Pausable: paused");
        adenoToken.transfer(user2, 10e18);
        vm.expectRevert("Pausable: paused");
        hoax(user);
        adenoToken.approve(user2, 100e18);
        vm.expectRevert("Pausable: paused");
        hoax(user2);
        adenoToken.transferFrom(user, treasury, 10e18);

        assertEq(adenoToken.balanceOf(user), 180e18);
        assertEq(adenoToken.balanceOf(user2), 10e18);
        assertEq(adenoToken.allowance(user, user2), 70e18);
    }

    function testTransferOwnership() public {
        address user2 = vm.addr(0x6);
        adenoToken.transferOwnership(user2);
        assertEq(adenoToken.owner(), user2);
    }
}
