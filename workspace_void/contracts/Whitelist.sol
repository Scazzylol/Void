// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./ERC20.sol";
import "./Ownable.sol";

// *********************************
// Whitelist Presale Contract
// *********************************
// cap increases gradually over time


contract Whitelist is Ownable {

    // the token address the cash is raised in
    // assume decimals is 18
    address public investToken;
    // proceeds go to treasury
    address public treasury;
    // Void Token Contract
    address public voidToken;
    // the certificate
    //NRT public nrt;
    // ratio quote in 1000
    uint256 public presalePrice;
    // the cap at the beginning
    uint256 public initialCap;
    // maximum cap
    uint256 public maxInvestorCap;
    // the total amount in stables to be raised
    uint256 public globalHardCap;
    // how much was raised
    uint256 public totalraised;
    // how much was issued
    uint256 public totalissued;
    // start of the sale
    uint256 public startTime;
    // total duration
    uint256 public duration;
    // length of each epoch
    uint256 public epochTime;
    // end of the sale
    uint256 public endTime;
    // sale has started
    bool public saleEnabled;
    // minimum amount
    uint256 public minInvest;
    // 
    uint256 public numWhitelisted = 0;
    // 
    uint256 public numInvested = 0;

    event SaleEnabled(bool enabled, uint256 time);
    event Invest(address investor, uint256 amount);

    struct InvestorInfo {
        uint256 amountInvested; // Amount deposited by user
        bool claimed; // has claimed MAG
    }

    // user is whitelisted
    mapping(address => bool) public whitelisted;

    mapping(address => InvestorInfo) public investorInfoMap;

    constructor(
        address _investToken,
        uint256 _startTime,
        uint256 _duration,
        uint256 _epochTime,
        uint256 _initialCap,
        uint256 _globalHardCap,
        uint256 _maxInvestorCap,
        uint256 _minInvest,
        uint256 _presalePrice,
        address _treasury,
        address _voidToken
    ) {
        investToken = _investToken;
        startTime = _startTime;
        duration = _duration;
        epochTime = _epochTime;
        initialCap = _initialCap;
        globalHardCap = _globalHardCap;
        maxInvestorCap = _maxInvestorCap; 
        minInvest = _minInvest;
        treasury = _treasury;
        voidToken = _voidToken;
        presalePrice = _presalePrice;
        endTime = startTime + duration;

        saleEnabled = false;
    }

    // adds an address to the whitelist
    function addWhitelist(address _address) external onlyOwner {
        require(!saleEnabled, "sale has already started");
        //require(!whitelisted[_address], "already whitelisted");
        if(!whitelisted[_address])
            numWhitelisted+=1;
        whitelisted[_address] = true;
    }

    // adds multiple addresses
    function addMultipleWhitelist(address[] calldata _addresses) external onlyOwner {
        require(!saleEnabled, "sale has already started");
        require(_addresses.length <= 1000, "too many addresses");
        for (uint256 i = 0; i < _addresses.length; i++) {
            if(!whitelisted[_addresses[i]])
                numWhitelisted+=1;
            whitelisted[_addresses[i]] = true;
        }
    }

    // removes a single address from the sale
    function removeWhitelist(address _address) external onlyOwner {
        require(!saleEnabled, "sale has already started");
        whitelisted[_address] = false;
    }

    function currentEpoch() public view returns (uint256){
        return (block.timestamp - startTime)/epochTime;
    }

    // the current cap. increases exponentially
    function currentCap() public view returns (uint256){
        uint256 epochs = currentEpoch();
        uint256 cap = initialCap * (2 ** epochs);
        if (cap > maxInvestorCap){
            return maxInvestorCap;
        } else {
            return cap;
        }
    }

    // invest up to current cap
    function invest(uint256 investAmount) public {
        require(block.timestamp >= startTime, "not started yet");
        require(endTime >= block.timestamp, "sale has ended");
        require(saleEnabled, "not enabled yet");
        require(whitelisted[msg.sender] == true, 'msg.sender is not whitelisted');
        require(totalraised + investAmount <= globalHardCap, "over global raise cap");
        require(investAmount >= minInvest, "below minimum invest");

        uint256 xcap = currentCap();

        InvestorInfo storage investor = investorInfoMap[msg.sender];

        require(investor.amountInvested + investAmount <= xcap, "above cap");

        // Require the DAI payment
        require(
            ERC20(investToken).transferFrom(
                msg.sender,
                address(this),
                investAmount
            ),
            "transfer failed"
        );

        uint256 issueAmount = investAmount * presalePrice;

        // Send out the void token
        ERC20(voidToken).transfer(
            msg.sender,
            issueAmount
        );

        totalraised += investAmount;
        totalissued += issueAmount;
        // Count new investors
        if (investor.amountInvested == 0){
            numInvested += 1;
        }
        investor.amountInvested += investAmount;

        emit Invest(msg.sender, investAmount);
    }

    // -- admin functions -- //

    // define the investment token
    function setInvestToken(address _investToken) public onlyOwner {
        investToken = _investToken;
    }

    //change the datetime for when the launch happens
    function setStartTime(uint256 _startTime) public onlyOwner {
        require(!saleEnabled, "sale has already started");
        startTime = _startTime;
        endTime = _startTime + duration;
    }

    // withdraw DAI funds to treasury
    function withdrawDAIToTreasury(uint256 amount) public onlyOwner {
        require(
            ERC20(investToken).transfer(treasury, amount),
            "transfer failed"
        );
    }

    function withdrawVoidToTreasury(uint256 amount) public onlyOwner {
        require(
            ERC20(voidToken).transfer(treasury, amount),
            "transfer failed"
        );
    }

    function withdrawTokenToTreasury(address token, uint256 amount) public onlyOwner {
        require(
            ERC20(token).transfer(treasury, amount),
            "transfer failed"
        );
    }

    function toggleSale() public onlyOwner {
        if(block.timestamp > endTime ) {
            saleEnabled = false;
            emit SaleEnabled(false, block.timestamp);
        } else {
            saleEnabled = true;
            emit SaleEnabled(true, block.timestamp);
        }
    }

    function toggleSaleOff() public onlyOwner {
        saleEnabled = false;
        emit SaleEnabled(false, block.timestamp);
    }

    function toggleSaleOn() public onlyOwner {
        saleEnabled = true;
        emit SaleEnabled(true, block.timestamp);
    }


} 
