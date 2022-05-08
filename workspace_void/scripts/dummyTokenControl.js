// Token Addr
const pVoid = '0x587F62D14196Eeb99e249Ad3Cf86458ED8c11764'
const DummyDAI = '0x5e5873FadBFda8F98d7721F80A73F99b868b7388'

// Wallet Addr
const wallet = '0x1783Ad78f0FEFCfa7e1d964D22a7c6e46c6EB4C7'
const wallet2 = '0xD4cf0aCafEd26e0241F05653Db06Fad377f7E56a'

const whitelistAddr = '0x8F07388Cb0aaB06f57052C47F2317cD8F754b7aa'

async function main() {
    [owner] = await ethers.getSigners();
    const IToken = await ethers.getContractFactory('DummyDAI');
    Token = await IToken.attach(DummyDAI);
    TokenControl = await Token.connect(owner);
    
    //await TokenControl.mint(wallet, 1000);
    //await TokenControl.burn(wallet, 50);
    //await TokenControl.transfer(whitelistAddr, ethers.BigNumber.from('1000000000000000000'));
    // TokenControl.transferFrom(wallet2, wallet, 100);
    //await TokenControl.approve(wallet2, 1140);

    //result = await TokenControl.convertToVoid(10)
    //result = await TokenControl.voidToken();

    result = await TokenControl.balanceOf(wallet);
    //result2 = await TokenControl.totalSupply();
    //result3 = await TokenControl.allowance(wallet,wallet2);

    console.log('Wallet Bal: ' + result);
    //console.log('Total Supply: ' + result2);
    //console.log('Allowance: ' + result3);

    console.log('');

}

function bigNumberify(input) {
    return ethers.BigNumber.from(input);
}

main()
