// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract InventoryContract{
    mapping(address => string) private inventoryIds;
    event InventoryUpdates(string ipfsId);

    function updateInventoryCID(address userAddress, string memory _inventoryId) public {
        inventoryIds[userAddress] = _inventoryId;
        
        emit InventoryUpdates(_inventoryId);
    }
    
    function getInventoryCID(address userAddress) public view returns (string memory) {
        return inventoryIds[userAddress];
    }
}