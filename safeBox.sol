//Licencia
// SPDX-License-Identifier: LGPL-3.0-only

//Version
pragma solidity 0.8.24;

contract safeBox{
    address public owner;

    constructor() {
        owner = msg.sender;
        isManager[owner] = true;
    }

     // Mapping of authorized manager addresses
    mapping(address => bool) public isManager;

    modifier onlyAutorized() {
        require(isManager[msg.sender], "Not authorized");
        _;
    }

    event DepositSuccess(address from, uint256 amount);
    event WithdrawSuccess(address to, uint256 amount);
    event ManagerAdded(address manager);
    event UnknownCall(address sender, uint256 value, bytes data);
    event DeletedManager(address manager);

    // Function to accept ETH and emit deposit event
    function depositEth() external payable {
        emit DepositSuccess(msg.sender, msg.value);
    }

    // Withdraws ETH to the caller if authorized
    function withdrawEth(uint256 amount) external onlyAutorized{
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        emit WithdrawSuccess(msg.sender, amount);
    }

    // Returns the ETH balance of the contract
    function getBalance() external view onlyAutorized returns (uint256) {
        return address(this).balance;
    }

    // Adds a new manager (only callable by owner)
    function addManager(address newManager) external onlyAutorized{
        require (msg.sender == owner, "Only owner can add managers");
        require(!isManager[newManager], "Already a manager");
        isManager[newManager] = true;
        emit ManagerAdded (newManager);
    }
    
    // Deletes a manager (only callable by owner)
    function deleteManager(address managerToRemove) external{
        require (msg.sender == owner, "Only owner can delete managers");
        require(isManager[managerToRemove], "Not a manager");
        isManager[managerToRemove] = false;
        emit DeletedManager (managerToRemove);
    }
    
    // Returns the address of the contract owner
    function getOwner() external view returns (address) {
        return owner;
    }

    // Receive ETH without triggering any function
    receive() external payable{ }

    // Fallback function that reverts any call to undefined functions
    fallback() external payable {
        revert("Fallback: function does not exist");
    }
    
}