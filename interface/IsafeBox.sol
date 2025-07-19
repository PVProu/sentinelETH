//Licencia
// SPDX-License-Identifier: LGPL-3.0-only

//Version
pragma solidity 0.8.24;

interface IsafeBox {
    function getBalance() external view returns (uint256);
    function withdrawEth(uint256 amount) external;
    function depositEth() external payable;
    function getOwner() external view returns (address);
    function addManager(address newManager) external;

}
