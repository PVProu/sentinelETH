# SentinelETH 🛡️

**SentinelETH** is a secure dual-contract Ethereum smart contract system built in Solidity. It separates concerns between vault management and access control by leveraging two contracts:

- `SafeBox`: A highly secure ETH vault with strict role-based access.
- `WalletManager`: A modular access control interface that allows delegated withdrawals and vault interaction by authorized users only.

This architecture is designed for scenarios requiring **secure ETH custody** with **externalized permission management**, such as DAOs, treasuries, custodial wallets, or automated systems.

---

## 🧱 Architecture Overview

- **SafeBox**
  - Holds ETH securely.
  - Allows withdrawals only to addresses authorized via the `isManager` mapping.
  - Only the contract `owner` can manage (add/remove) managers.
  - Emits detailed events for all operations.

- **WalletManager**
  - Acts as the only interface between users and the vault.
  - Owner-managed authorization system (users must be explicitly authorized).
  - Forwards ETH to `SafeBox` and interacts with it on behalf of authorized users.
  - Emits logs for all authorization and ETH operations.

---

## 🔐 Key Features

- ✅ Role-based access control with two-layer security
- ✅ Modular authorization via the `WalletManager`
- ✅ Secure withdrawal flow, only via authorized calls
- ✅ Transparent logging of deposits, withdrawals, and permission changes
- ✅ Fallback and receive functions for safety and traceability
- ✅ Forwarding function to route ETH from the vault to external users

---

## 🔧 Deployment Guide

To deploy the **SentinelETH** system properly, follow these steps:

1. **Deploy the `SafeBox` contract first**
   - This contract will serve as the ETH vault.
   - The deployer is automatically set as `owner` and a `manager`.

2. **Deploy the `WalletManager` contract**
   - Pass the deployed `SafeBox` address as the constructor parameter.

3. **Manually authorize the `WalletManager` inside `SafeBox`**
   - Since `SafeBox` does not automatically trust any external contract, you must explicitly call:
     ```solidity
     addManager(address_of_WalletManager)
     ```
     from the `SafeBox` owner's address.

   > ⚠️ **This step is mandatory.** Without it, `WalletManager` will not be able to call any restricted functions on `SafeBox`.

---

## 📂 Contracts Summary

### `SafeBox.sol`

- `mapping(address => bool) isManager`: Tracks who can access vault functions.
- `depositEth()`: Accepts ETH into the vault.
- `withdrawEth(uint256)`: Sends ETH to the authorized caller.
- `addManager(address)`: Grants manager access (only by `owner`).
- `getBalance()`: Returns contract's ETH balance.
- `getOwner()`: Returns current owner address.
- `fallback()` and `receive()`: Handle unexpected calls and ETH transfers safely.

### `WalletManager.sol`

- `mapping(address => bool) isAuthorized`: Tracks user-level access.
- `requestWithdraw(uint256)`: Triggers withdrawal via `SafeBox`.
- `sendEth()`: Forwards ETH to `SafeBox`.
- `checkBalance()`: Retrieves `SafeBox` balance.
- `requestOwner()`: Reads the `SafeBox` owner address.
- `forwardToUser(address, uint256)`: Sends ETH from contract to an external user (after withdrawal from vault).

---

## 📜 License

This project is licensed under the **LGPL-3.0-only** License.

---

## ✒️ Naming Convention

**SentinelETH** reflects the dual responsibility of:
- *Sentinel*: The `WalletManager` guarding and controlling access
- *ETH*: The asset being stored and protected

---

## 📩 Contact & Usage

This project is built for educational and security demonstration purposes.  
Feel free to fork, audit, or expand upon it in your Web3 project.  
If you use it in production, **audit the code carefully** and apply best practices.

---

## 📫 Author

**SentinelETH** by Pol VELA
Secure ETH custody made modular.
