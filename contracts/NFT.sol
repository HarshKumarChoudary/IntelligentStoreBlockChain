// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds; // The token id of the NFTs, also equal to the number of token.
    address contractAddress; // Address of the NFT token Contract

    constructor(address marketPlaceAddress) ERC721("Unique Store Tokens", "UST") {
        contractAddress = marketPlaceAddress;
    }

    // overriding create NFT Token function.
    function createToken(string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current(); 
        _mint(msg.sender, newTokenId); 
        _setTokenURI(newTokenId, tokenURI); 
        setApprovalForAll(contractAddress, true); 
        return newTokenId;
    }
}