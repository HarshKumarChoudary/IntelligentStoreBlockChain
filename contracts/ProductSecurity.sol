// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract ProductSecurity {

    struct Product {
        address owner;
        string name;
        string description;
        uint256 dateCreated;
        string extras;
    }
    
    mapping(address => mapping(uint256 => Product)) public prodcuts;

    function createProduct(address _owner, string[] memory _name, string[] memory _description, uint256[] memory _isbn) public {

        uint256 len = _name.length;

        for(uint256 i = 0; i < len; ++ i){
            Product storage prodcut = prodcuts[_owner][_isbn[i]];
            require(prodcut.owner == address(0), "The ISBN Number shall be unique");
        }

        for(uint256 i = 0; i < len; ++ i){
            Product storage prodcut = prodcuts[_owner][_isbn[i]];
            prodcut.owner = _owner;
            prodcut.name = _name[i];
            prodcut.description = _description[i];
            prodcut.dateCreated = block.timestamp;
            prodcut.extras = "";
        }
        
    }

    function getProduct(address _owner, uint256 isbn) public view returns (Product memory) {
        return prodcuts[_owner][isbn];
    }
}