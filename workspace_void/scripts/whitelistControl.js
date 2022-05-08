whitelistAddr = '0x8F07388Cb0aaB06f57052C47F2317cD8F754b7aa';

const wallet = '0x1783Ad78f0FEFCfa7e1d964D22a7c6e46c6EB4C7'
const wallet2 = '0xD4cf0aCafEd26e0241F05653Db06Fad377f7E56a'

const arr = [wallet,wallet2]

DAIaddr = '0xDA1430f5F3d9E6DC3232211532026bF101Daf83F'
voidAddr = '0xb6D812F90E2384eE10a3477533cDA50306e5180C'

async function main() {
    [owner] = await ethers.getSigners();
    const IWhitelist = await ethers.getContractFactory('Whitelist');
    Whitelist = await IWhitelist.attach(whitelistAddr);
    WhitelistControl = await Whitelist.connect(owner);

    
    //result = await WhitelistControl.toggleSaleOn();
    //result = await WhitelistControl.isSaleOn();
    //result = await WhitelistControl.saleStartTime();
    //result = await WhitelistControl.addWhitelist(wallet);
    //result = await WhitelistControl.removeWhitelist(wallet);
    //result = await WhitelistControl.addMultipleWhitelist(arr);
    //result = await WhitelistControl.isUserWhitelisted(wallet);
    //result = await WhitelistControl.setInvestToken(DAIaddr);
    //result = await WhitelistControl.currentCap();
    //result = await WhitelistControl.currentEpoch();
    //result = await WhitelistControl.setStartTime(1651014600);
    //result = await WhitelistControl.withdrawDAIToTreasury(1000);
    //result = await WhitelistControl.withdrawVoidToTreasury(1000);
    //result = await WhitelistControl.treasury(); // Get the public variable


    result = await WhitelistControl.invest(500); // Error in the invest function
    //result = await WhitelistControl.investorInvested(wallet);


    console.log(result);
    console.log('');

}


main()
