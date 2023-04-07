// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; 
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ProductStore is ReentrancyGuard, Ownable {

    address payable ownerContract; 
    uint256 listingPrice = 0.00001 ether;

    constructor() {
        ownerContract = payable(msg.sender);
    }

    struct Product {
        address payable manufacturer;
        bytes32 productId;
        address payable[] owners;
        string title;
        string description;
        uint256 dateCreated;
        uint256 price;
        uint256 isbn;
        bool isListed;
    }
    
    mapping(bytes32 => Product) private idToProduct;
    mapping(address => mapping(bytes32 => Product)) public addressToProductIdTodetails;
    mapping(address => string) public addressToName;

    function getOwnerContract() public view returns (address){
        return ownerContract;
    }

    function registerStore(string memory _Name) public {
        addressToName[msg.sender] = _Name;
    }

    function getStoreName() public view returns(string memory){
        return addressToName[msg.sender];
    }

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    function createProduct(string[] memory _title, string[] memory _description, uint256[] memory _isbn, uint256[] memory _price) public nonReentrant returns (bytes32[] memory){

        uint256 len = _title.length;

        for(uint256 i = 0; i < len; ++ i){
            string memory concatstring = string(bytes.concat(bytes(_title[i]), " ", abi.encodePacked(_isbn[i])));
            bytes32 productid = keccak256(abi.encode(concatstring));
            Product storage prodcut = addressToProductIdTodetails[msg.sender][productid];
            require(prodcut.manufacturer == address(0), "The product details should be unique");
        }

        bytes32[] memory productsid = new bytes32[](len);
        uint256 k = 0;

        for(uint256 i = 0; i < len; ++ i){
            string memory concatstring = string(bytes.concat(bytes(_title[i]), " ", abi.encodePacked(_isbn[i])));
            bytes32 productid = keccak256(abi.encode(concatstring));
            Product storage prodcut = addressToProductIdTodetails[msg.sender][productid];
            prodcut.owners.push(payable(msg.sender));
            prodcut.manufacturer = payable(msg.sender);
            prodcut.title = _title[i];
            prodcut.description = _description[i];
            prodcut.dateCreated = block.timestamp;
            prodcut.isbn = _isbn[i];
            prodcut.price = _price[i];
            prodcut.isListed = false;
            prodcut.productId = productid;
            idToProduct[productid] = prodcut;
            productsid[k] = productid;
            k ++;
        }
        return productsid;
    }

    function listProductForSale(bytes32 productid) public {
        require(idToProduct[productid].owners[idToProduct[productid].owners.length-1] == msg.sender, "You does not own the product! You can't list it");
        Product storage prodcut = idToProduct[productid];
        prodcut.isListed = true;
    }

    function buyTheProduct(bytes32 productid) public payable nonReentrant {
        require(msg.value >= listingPrice, "You need to pay the listing price");
        require(idToProduct[productid].isListed == true, "The product is not available to purchase");
        idToProduct[productid].owners.push(payable(msg.sender));
        idToProduct[productid].isListed = false;
        payable(ownerContract).transfer(listingPrice);
    }

    function getProductDetails(bytes32 productid) public view returns (Product memory) {
        return idToProduct[productid];
    }

    function withdraw(address _recipient) public payable onlyOwner {
        payable(_recipient).transfer(address(this).balance);
    }
}