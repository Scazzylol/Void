// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "lib/forge-std/src/Test.sol";

import {Whitelist} from "../contracts/Whitelist.sol";
import {DummyDAI}  from "../contracts/DummyDAI.sol";
import {pVoid}     from "../contracts/pVoid.sol";
import {DummyTreasury}  from "../contracts/DummyTreasury.sol";


contract WhitelistTest is Test {
    Whitelist wlist;
    DummyDAI ddai;
    pVoid pvoid;
    DummyTreasury treasury;

    uint256 startTime = (block.timestamp + 1 days); // Calc the start time // 15:05 today
    uint256 saleDuration = 86400; // ASK 
    uint256 epochLength = 900; // 15 min is 900 seconds 
    uint256 initialCap = 500; // Initial DAI investment cap of 500 
    uint256 globalHardCap = 1_250_000; // Hard cap 1.25 Mil DAI
    uint256 maxInvestorCap = 4000; // 4000 DAI investor cap
    uint256 minInvest = 50; // 50 DAI Min investment
    uint256 presalePrice = 1; // Price $1 (in real decimals, not ethers)

    address testWallet = 0x1783Ad78f0FEFCfa7e1d964D22a7c6e46c6EB4C7;
    address testWallet2 = 0xF46D3a64d546d9Cec0883E5FbBA04583363df24c;

    function setUp() public {
        ddai = new DummyDAI(
            200_000
        );

        pvoid = new pVoid(
            200_000,
            address(ddai)
        );

        treasury = new DummyTreasury(
            address(pvoid),
            address(ddai)
        );

        wlist = new Whitelist(
            address(ddai),
            startTime,
            saleDuration,
            epochLength,
            initialCap,
            globalHardCap,
            maxInvestorCap,
            minInvest,
            presalePrice,
            address(treasury),
            address(pvoid)
        );
    }

    function test_addWhitelist() public {
        wlist.addWhitelist(testWallet);
        require(wlist.isUserWhitelisted(testWallet) == true);
        wlist.removeWhitelist(testWallet);
        require(wlist.isUserWhitelisted(testWallet) == false);
    }

    function test_invest() public {
        // whitelist the test wallet
        wlist.addWhitelist(testWallet);
        wlist.addWhitelist(testWallet2);
        require(wlist.isUserWhitelisted(testWallet) == true);
        require(wlist.isUserWhitelisted(testWallet2) == true);

        wlist.toggleSale();
        require(wlist.isSaleOn() == false);
        vm.warp(block.timestamp + 1 days);
        wlist.toggleSale();
        require(wlist.isSaleOn() == true);
        wlist.toggleSaleOff();
        require(wlist.isSaleOn() == false);
        wlist.toggleSaleOn();
        require(wlist.isSaleOn() == true);

        // Transfer dummy dai to the wallet and pvoid to the contract
        ddai.transfer(testWallet, 100_000);
        ddai.transfer(testWallet2, 100_000);
        pvoid.transfer(address(wlist), 200_000);
        require(ddai.balanceOf(testWallet) == 100_000);
        require(pvoid.balanceOf(address(wlist)) == 200_000);


        // Test the invest function 
        vm.startPrank(testWallet);
        // Approve the spend limit
        ddai.approve(address(wlist), type(uint256).max);

        uint256 investAmt = 60;
        wlist.invest(investAmt);
        require(wlist.investorInvested(testWallet) == investAmt);
        require(wlist.currentCap() == 500);
        wlist.invest(440);
        require(wlist.investorInvested(testWallet) == 500);
        vm.stopPrank();


        vm.startPrank(testWallet2);
        // Approve the spend limit
        ddai.approve(address(wlist), type(uint256).max);

        wlist.invest(500);
        require(wlist.investorInvested(testWallet2) == 500);

        vm.warp(block.timestamp + 15 minutes);
        require(wlist.currentCap() == 1000);
        wlist.invest(500);
        require(wlist.investorInvested(testWallet2) == 1000);

        vm.warp(block.timestamp + 15 minutes);
        require(wlist.currentCap() == 2000);
        wlist.invest(1000);
        require(wlist.investorInvested(testWallet2) == 2000);

        vm.warp(block.timestamp + 15 minutes);
        require(wlist.currentCap() == 4000);
        wlist.invest(2000);
        require(wlist.investorInvested(testWallet2) == 4000);

        vm.warp(block.timestamp + 2 days); // There is a cap overflow if sale is for too many days
        require(wlist.currentCap() == 4000);

        require(wlist.returnNumInvested() == 2);
        require(wlist.returnMumberWhitelisted() == 2);
        
        vm.stopPrank();

        // Transfer tokens to treasury
        wlist.withdrawpVoidToTreasury(100);
        require(pvoid.balanceOf(address(treasury)) == 100);

    }


    // Token Tests
    function test_dummyTokens() public {

        // Init Dummy DAI and give the wallet 1 ether
        uint256 dDAIAmount = 1000;
        ddai.transfer(testWallet, dDAIAmount);
        require(ddai.balanceOf(testWallet) == dDAIAmount);

        ddai.mint(testWallet, dDAIAmount);
        require(ddai.balanceOf(testWallet) == dDAIAmount*2);

        vm.startPrank(testWallet);
        ddai.burn(dDAIAmount); 
        require(ddai.balanceOf(testWallet) == dDAIAmount);

        // Transfer the dummyDAI to the pvoid contract 
        ddai.transfer(address(pvoid), dDAIAmount);
        require(ddai.balanceOf(address(pvoid)) == 1000);
        require(pvoid.getVoidTokenAddress() == address(ddai));
        vm.stopPrank();


        // Init pVoid, and sub DummyDAI as the void token
        pvoid.transfer(testWallet, 1000);
        require(pvoid.balanceOf(testWallet) == 1000);


        // Test the pVoid redeem function 
        vm.startPrank(testWallet);
        // Approval
        pvoid.approve(address(pvoid), type(uint256).max);
        pvoid.convertToVoid(1000);
    }

}
