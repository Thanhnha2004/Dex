// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;
// import {console} from "lib/forge-std/src/Script.sol";

// import {Test} from "lib/forge-std/src/Test.sol";
// import {Dex} from "src/core/Dex.sol";
// import {DeployDex} from "script/DeployDex.s.sol";
// import {console} from "lib/forge-std/src/console.sol";

// contract DexTest is Test {
//     //////////////////////////////////////////////////////////
//     ////////////////  Storage Variables  /////////////////////
//     //////////////////////////////////////////////////////////
//     Dex dex;

//     //getMyHoldings()
//     uint256 public userToken1Bal;
//     uint256 public userToken2Bal;
//     uint256 public providerShares;

//     //getPoolDetails()
//     uint256 public totalShares;
//     uint256 public totalToken1;
//     uint256 public totalToken2;

//     //getWithdrawEstimate()
//     uint256 public amountToken1;
//     uint256 public amountToken2;

//     address private user1 = makeAddr("user1");
//     address private user2 = makeAddr("user2");
//     address private MINTER_ROLE = makeAddr("MINTER_ROLE");
//     address private BURNER_ROLE = makeAddr("BURNER_ROLE");

//     //////////////////////////////////////////////////////////
//     //////////////////////   Events  /////////////////////////
//     //////////////////////////////////////////////////////////
//     // event InitialLiquidityProvided(
//     //     address indexed provider, 
//     //     uint256 amountToken1, 
//     //     uint256 amountToken2,
//     //     uint256 share
//     // );

//     // event LiquidityProvided(
//     //     address indexed provider, 
//     //     uint256 amountToken1, 
//     //     uint256 amountToken2,
//     //     uint256 share
//     // );

//     // event Withdraw(
//     //     address indexed withdrawer, 
//     //     uint256 share, 
//     //     uint256 amountToken1, 
//     //     uint256 amountToken2
//     // );

//     function setUp() external {
//         DeployDex deployer = new DeployDex();
//         dex = deployer.run();

//         vm.prank(address(this));
//         dex.grantMINTER_ROLE(MINTER_ROLE);

//         vm.prank(address(this));
//         dex.grantBURNER_ROLE(BURNER_ROLE);
//     }

//     function test_mint() public {
//         vm.prank(user1);
//         dex.mint(MINTER_ROLE, 1);
//     }

//     function test_burn() public {
//         vm.prank(BURNER_ROLE);
//         dex.burn(BURNER_ROLE, 1);
//     }

//     // //////////////////////////////////////////////////////////
//     // ///////////////////  Provide Tests  //////////////////////
//     // //////////////////////////////////////////////////////////
//     // modifier InitialLiq() {
//     //     vm.startPrank(user1);
//     //     dex.faucet(100, 100);

//     //     dex.provide(50, 75);

//     //     vm.stopPrank();
//     //     _;
//     // }

//     // function test_Provide_RevertIf_Token1AmountZero() public {
//     //     vm.startPrank(user1);
//     //     dex.faucet(10, 10);

//     //     vm.expectRevert(Dex.DEX__AmountCanNotBeZero.selector);
//     //     dex.provide(0, 5);
//     //     vm.stopPrank();
//     // }

//     // function test_Provide_RevertIf_Token2AmountZero() public {
//     //     vm.startPrank(user1);
//     //     dex.faucet(10, 10);

//     //     vm.expectRevert(Dex.DEX__AmountCanNotBeZero.selector);
//     //     dex.provide(5, 0);
//     //     vm.stopPrank();
//     // }

//     // function test_Provide_RevertIf_UserBal1InsufficientAmount() public {
//     //     vm.startPrank(user1);
//     //     dex.faucet(5, 10);

//     //     vm.expectRevert(Dex.DEX__InsufficientAmount.selector);
//     //     dex.provide(10, 10);
//     //     vm.stopPrank();
//     // }

//     // function test_Provide_RevertIf_UserBal2InsufficientAmount() public {
//     //     vm.startPrank(user1);
//     //     dex.faucet(10, 5);

//     //     vm.expectRevert(Dex.DEX__InsufficientAmount.selector);
//     //     dex.provide(10, 10);
//     //     vm.stopPrank();
//     // }

//     // function test_Provide_RevertIf_NotEquivalentValue() public InitialLiq {
//     //     vm.startPrank(user2);
//     //     dex.faucet(20, 20);

//     //     vm.expectRevert(Dex.DEX__NotEquivalentValue.selector);
//     //     dex.provide(5, 10);
//     //     vm.stopPrank();
//     // }

//     // function test_Provide_InitialLiq() public {
//     //     vm.startPrank(user1);
//     //     dex.faucet(10, 10);

//     //     uint256 share = dex.provide(5, 5);
//     //     (totalToken1, totalToken2, totalShares) = dex.getPoolDetails();
//     //     (userToken1Bal, userToken2Bal, providerShares) = dex.getMyHoldings();

//     //     assertEq(share, 100e6);
//     //     assertEq(share, totalShares);
//     //     assertEq(totalToken1, 5);
//     //     assertEq(totalToken2, 5);
//     //     assertEq(userToken1Bal, 5);
//     //     assertEq(userToken2Bal, 5);
//     //     assertEq(providerShares, 100e6);
//     //     vm.stopPrank();
//     // }

//     // function test_Provide_Success() public InitialLiq {
//     //     vm.startPrank(user2);

//     //     (uint256 initialTotalToken1, , uint256 initialTotalShares) = dex.getPoolDetails();

//     //     dex.faucet(20, 20);

//     //     uint256 share = dex.provide(10, 10);
//     //     (totalToken1, totalToken2, totalShares) = dex.getPoolDetails();
//     //     (userToken1Bal, userToken2Bal, providerShares) = dex.getMyHoldings();

//     //     assertEq(share, initialTotalShares * 10 / initialTotalToken1);
//     //     assertEq(totalShares, initialTotalShares + share);
//     //     assertEq(totalToken1, 15);
//     //     assertEq(totalToken2, 15);
//     //     assertEq(userToken1Bal, 10);
//     //     assertEq(userToken2Bal, 10);
//     //     assertEq(providerShares, share);
//     //     vm.stopPrank();
//     // }

//     // function test_Provide_Emit_InitialLiquidityProvided() public {
//     //     vm.startPrank(user1);
//     //     dex.faucet(10, 10);

//     //     vm.expectEmit();
//     //     emit InitialLiquidityProvided(user1, 5, 5, 100e6);

//     //     dex.provide(5, 5);
//     //     vm.stopPrank();
//     // }

//     // function test_Provide_Emit_LiquidityProvided() public InitialLiq {
//     //     vm.startPrank(user2);
//     //     dex.faucet(20, 20);

//     //     uint256 expectedShare = 200e6;

//     //     vm.expectEmit();
//     //     emit LiquidityProvided(user2, 10, 10, expectedShare);

//     //     dex.provide(10, 10);
//     //     vm.stopPrank();
//     // }

//     // //////////////////////////////////////////////////////////
//     // ///////////////////  Withdraw Tests  /////////////////////
//     // //////////////////////////////////////////////////////////
//     // function test_Withdraw_RevertIf_ShareAmountZero() public InitialLiq {
//     //     vm.prank(user1);
//     //     vm.expectRevert(Dex.DEX__AmountCanNotBeZero.selector);
//     //     dex.withdraw(0);
//     // }

//     // function test_Withdraw_RevertIf_UserSharesBalInsufficientAmount() public InitialLiq {
//     //     vm.prank(user1);
//     //     vm.expectRevert(Dex.DEX__InsufficientAmount.selector);
//     //     dex.withdraw(150e6);
//     // }

//     // // function test_Withdraw_RevertIf_ShareMoreThanTotalShares() public InitialLiq {
//     // //     vm.prank(user1);
//     // //     vm.expectRevert(Dex.DEX__ShareMoreThanTotalShares.selector);
//     // //     dex.withdraw(150e6);
//     // // }

//     // function test_Withdraw_Success() public InitialLiq {
//     //     vm.startPrank(user1);
//     //     uint256 shareToWithdraw = 50e6;
        
//     //     (uint256 prevUserToken1Bal, uint256 prevUserToken2Bal, uint256 prevProviderShares) = dex.getMyHoldings();
//     //     (uint256 prevTotalToken1, uint256 prevTotalToken2, uint256 prevTotalShares) = dex.getPoolDetails();

//     //     (amountToken1, amountToken2) = dex.getWithdrawEstimate(shareToWithdraw);
//     //     dex.withdraw(shareToWithdraw);

//     //     (totalToken1, totalToken2, totalShares) = dex.getPoolDetails();
//     //     (userToken1Bal, userToken2Bal, providerShares) = dex.getMyHoldings();
//     //     vm.stopPrank();

//     //     console.log(prevProviderShares, providerShares);
//     //     assertEq(providerShares, prevProviderShares - shareToWithdraw);
//     //     assertEq(totalShares, prevTotalShares - shareToWithdraw);
//     //     assertEq(totalToken1, prevTotalToken1 - amountToken1);
//     //     assertEq(totalToken2, prevTotalToken2 - amountToken2);
//     //     assertEq(userToken1Bal, prevUserToken1Bal + amountToken1);
//     //     assertEq(userToken2Bal, prevUserToken2Bal + amountToken2);
//     // }

//     // function test_Withdraw_Emit_Withdraw() public InitialLiq {
//     //     vm.startPrank(user1);

//     //     uint256 shareToWithdraw = 50e6;

//     //     (amountToken1, amountToken2) = dex.getWithdrawEstimate(shareToWithdraw);

//     //     vm.expectEmit();
//     //     emit Withdraw(user1, shareToWithdraw, amountToken1, amountToken2);

//     //     dex.withdraw(shareToWithdraw);
//     //     vm.stopPrank();
//     // }

//     // //////////////////////////////////////////////////////////
//     // /////////////////////  Swap Tests  ///////////////////////
//     // //////////////////////////////////////////////////////////
//     // function test_Swap_RevertIf_ZeroLiq() public {
//     //     vm.startPrank(user2);
//     //     vm.expectRevert(Dex.DEX__ZeroLiquidity.selector);
//     //     dex.swapToken1(10);
//     //     vm.stopPrank();
//     // }

//     // function test_Swap_RevertIf_Token1AmountZero() public InitialLiq {
//     //     vm.startPrank(user2);

//     //     vm.expectRevert(Dex.DEX__AmountCanNotBeZero.selector);
//     //     dex.swapToken1(0);
//     //     vm.stopPrank();
//     // }

//     // function test_Swap_RevertIf_Token2AmountZero() public InitialLiq {
//     //     vm.startPrank(user2);

//     //     vm.expectRevert(Dex.DEX__AmountCanNotBeZero.selector);
//     //     dex.swapToken2(0);
//     //     vm.stopPrank();
//     // }

//     // function test_Swap_RevertIf_UserBal1InsufficientAmount() public InitialLiq {
//     //     vm.startPrank(user2);

//     //     vm.expectRevert(Dex.DEX__InsufficientAmount.selector);
//     //     dex.swapToken1(20);
//     //     vm.stopPrank();
//     // }

//     // function test_Swap_RevertIf_UserBal2InsufficientAmount() public InitialLiq {
//     //     vm.startPrank(user2);

//     //     vm.expectRevert(Dex.DEX__InsufficientAmount.selector);
//     //     dex.swapToken2(20);
//     //     vm.stopPrank();
//     // }

//     // function test_Swap_SwapToken1() public InitialLiq {
//     //     vm.startPrank(user2);
//     //     dex.faucet(100, 100);

//     //     (uint256 prevUserToken1Bal, uint256 prevUserToken2Bal, ) = dex.getMyHoldings();
//     //     (uint256 prevTotalToken1, uint256 prevTotalToken2, ) = dex.getPoolDetails();

//     //     uint256 amountToken1ToSwap = 50;
//     //     (amountToken2) = dex.getSwapToken1Estimate(amountToken1ToSwap);
//     //     dex.swapToken1(50);
//     //     (totalToken1, totalToken2, ) = dex.getPoolDetails();
//     //     (userToken1Bal, userToken2Bal, ) = dex.getMyHoldings();

//     //     assertEq(prevUserToken1Bal - amountToken1ToSwap, userToken1Bal);
//     //     assertEq(prevTotalToken1 + amountToken1ToSwap, totalToken1);
//     //     assertEq(prevTotalToken2 - amountToken2, totalToken2);
//     //     assertEq(prevUserToken2Bal + amountToken2, userToken2Bal);
//     //     vm.stopPrank();
//     // }

//     // function test_Swap_SwapToken2() public InitialLiq {
//     //     vm.startPrank(user2);
//     //     dex.faucet(100, 100);

//     //     (uint256 prevUserToken1Bal, uint256 prevUserToken2Bal, ) = dex.getMyHoldings();
//     //     (uint256 prevTotalToken1, uint256 prevTotalToken2, ) = dex.getPoolDetails();

//     //     (amountToken1) = dex.getSwapToken2Estimate(50);
//     //     dex.swapToken2(50);
//     //     (totalToken1, totalToken2, ) = dex.getPoolDetails();
//     //     (userToken1Bal, userToken2Bal, ) = dex.getMyHoldings();

//     //     assertEq(prevUserToken2Bal - 50, userToken2Bal);
//     //     assertEq(prevTotalToken2 + 50, totalToken2);
//     //     assertEq(prevTotalToken1 - amountToken1, totalToken1);
//     //     assertEq(prevUserToken1Bal + amountToken1, userToken1Bal);
//     //     vm.stopPrank();
//     // }

//     // //////////////////////////////////////////////////////////
//     // ////////////////////  Getter Tests  //////////////////////
//     // //////////////////////////////////////////////////////////
//     // function test_GetMyHoldings() public {
//     //     dex.faucet(10, 20);
//     //     (userToken1Bal, userToken2Bal, providerShares) = dex.getMyHoldings();

//     //     assertEq(userToken1Bal, 10);
//     //     assertEq(userToken2Bal, 20);
//     //     assertEq(providerShares, 0);
//     // }

//     // function test_GetPoolDetails() public InitialLiq {
//     //     (totalToken1, totalToken2, totalShares) = dex.getPoolDetails();

//     //     assertEq(totalToken1, 50);
//     //     assertEq(totalToken2, 50);
//     //     assertEq(totalShares, 100e6);
//     // }

//     // function test_GetEquivalentToken1Estimate() public InitialLiq {
//     //     (uint256 reqToken1) = dex.getEquivalentToken1Estimate(25);
//     //     (totalToken1, totalToken2, totalShares) = dex.getPoolDetails();

//     //     assertEq(reqToken1, totalToken1 * 25 / totalToken2);
//     // }

//     // function test_GetEquivalentToken2Estimate() public InitialLiq {
//     //     (uint256 reqToken2) = dex.getEquivalentToken2Estimate(28);
//     //     (totalToken1, totalToken2, totalShares) = dex.getPoolDetails();

//     //     assertEq(reqToken2, totalToken2 * 28 / totalToken1);
//     // }

//     // function test_GetWithdrawEstimate() public InitialLiq {
//     //     (amountToken1, amountToken2) = dex.getWithdrawEstimate(50);
//     //     (totalToken1, totalToken2, totalShares) = dex.getPoolDetails();

//     //     assertEq(amountToken1, 50 * totalToken1 / totalShares);
//     //     assertEq(amountToken2, 50 * totalToken2 / totalShares);
//     // }

//     // function test_GetSwapToken1Estimate() public InitialLiq {
//     //     (amountToken2) = dex.getSwapToken1Estimate(50);
//     //     (totalToken1, totalToken2, ) = dex.getPoolDetails();

//     //     uint256 totalToken1After = totalToken1 + 50;
//     //     uint256 totalToken2After = (totalToken1 * totalToken2) / totalToken1After;

//     //     assertEq(amountToken2, totalToken2 - totalToken2After);
//     // }

//     // function test_RevertIf_InsufficientPoolBal() public InitialLiq {
//     //     vm.startPrank(user2);
//     //     dex.faucet(200, 200);

//     //     vm.expectRevert(Dex.DEX__InsufficientPoolBal.selector);
//     //     dex.getSwapToken1EstimateGivenToken2(100);

//     //     vm.stopPrank();
//     // }

//     // function test_GetSwapToken1EstimateGivenToken2() public InitialLiq {
//     //     (amountToken1) = dex.getSwapToken1EstimateGivenToken2(40);
//     //     (totalToken1, totalToken2, ) = dex.getPoolDetails();

//     //     uint256 token2After = totalToken2 - 40;
//     //     uint256 token1After = (totalToken1 * totalToken2) / token2After;

//     //     assertEq(amountToken1, token1After - totalToken1);
//     // }

//     // function test_GetSwapToken2Estimate() public InitialLiq {
//     //     (amountToken1) = dex.getSwapToken2Estimate(20);
//     //     (totalToken1, totalToken2, ) = dex.getPoolDetails();

//     //     uint256 token2After = totalToken2 + 20;
//     //     uint256 token1After = (totalToken1 * totalToken2) / token2After;

//     //     assertEq(amountToken1, totalToken1 - token1After);
//     // }

//     // function test_GetSwapToken2EstimateGivenToken1() public InitialLiq {
//     //     (amountToken2) = dex.getSwapToken2EstimateGivenToken1(35);
//     //     (totalToken1, totalToken2, ) = dex.getPoolDetails();

//     //     uint256 token1After = totalToken1 - 35;
//     //     uint256 token2After = (totalToken1 * totalToken2) / token1After;

//     //     assertEq(amountToken2, token2After - totalToken2);
//     // }
// }