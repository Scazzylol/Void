// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract pVoid is ERC20, Ownable { 
    address public voidToken; 

    event Redeem(address investor, uint256 amount);

    constructor (
        uint256 initSupply,
        address voidTokenAddress_
    ) ERC20("pVoid", "pVoid") {
        _mint(msg.sender, initSupply);
        voidToken = voidTokenAddress_;
    } 

    // The function for converting pVoid to void 1:1 
    function convertToVoid(uint256 amount) external {
        // Require the pVoid payment
        require(
            ERC20(address(this)).transferFrom(
                msg.sender,
                address(this),
                amount
            ),
            "transfer failed"
        );
        
        ERC20(voidToken).transfer(
            msg.sender,
            amount
        );
        emit Redeem(msg.sender, amount);
    }
    
    // Admin functions
    function setVoidTokenAddress(address token) external onlyOwner {
        voidToken = token;
    } 

    function getVoidTokenAddress() external view returns (address) {
        return voidToken;
    }
}
