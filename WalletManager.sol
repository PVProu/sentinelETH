//Licencia
// SPDX-License-Identifier: LGPL-3.0-only

//Version
pragma solidity 0.8.24;

import "./interface/IsafeBox.sol";

// Custom error for unauthorized access
error SenderNotAdmin(address);

contract WalletManager{

    address public owner;
    address public vaultAddress;

     // Constructor sets the deployer as owner and sets the vault address
    constructor(address vaultAddress_) {
        owner = msg.sender;
        isAutorized[owner] = true;
        vaultAddress = vaultAddress_;
    }
    
    // Mapping of authorized manager addresses
    mapping(address=>bool) public isAutorized;

    event UserAuthorized(address user);
    event UserDeleted(address user);
    event EthSentToVault(address  sender, uint256 amount);
    event WithdrawRequested(address from, uint256 amount);

     // Returns the address of the connected vault
    function getVaultAddress() external view returns (address){
        return vaultAddress;
    }

     // Authorize a user (internal permission system)
    function autorizeUser(address manager_) external {
        require(msg.sender == owner, "Only owner can autorize");
        isAutorized[manager_] = true;
        emit UserAuthorized(manager_);
    }

    // Remove a user from authorized list
    function deleteUser(address manager_) external {
        if (msg.sender != owner) revert SenderNotAdmin(msg.sender);
        isAutorized[manager_] = false;
        emit UserDeleted(manager_);
    }

     // Request withdrawal from the vault (if user is authorized)
    function requestWithdraw(uint256 amount_) external {
        require(isAutorized[msg.sender], "Only autorized users can withdraw");
        IsafeBox(vaultAddress).withdrawEth(amount_);
        emit WithdrawRequested(msg.sender, amount_);    
    }

     // Send ETH to the vault
    function sendEth() public payable {
        IsafeBox(vaultAddress).depositEth{value: msg.value}();
        emit EthSentToVault(msg.sender, msg.value);
    }

     // Get vault balance (if authorized)
    function checkBalance () public view returns (uint256) {
        require(isAutorized[msg.sender], "Only autorized users can check the balance");
        return IsafeBox(vaultAddress).getBalance();
    }
    
    // Get vault owner (if authorized)
    function requestOwner() public view returns (address) {
        require(isAutorized[msg.sender], "Only authorized can see it");
        return IsafeBox(vaultAddress).getOwner();
    }

    receive() external payable {}

    fallback() external payable {}

    function forwardToUser(address user, uint256 amount) external {
        require(isAutorized[msg.sender], "Not authorized");
        (bool success,) = user.call{value: amount}("");
        require(success, "Transfer to user failed");
    }

}