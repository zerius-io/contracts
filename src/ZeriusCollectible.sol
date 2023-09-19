// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
//import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
//import "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract ZeriusCollectible is ERC721URIStorage {

    uint256 public tokenCounter;

    constructor(address _VRFCoordinator, uint64 _subscriptionId, bytes32 _keyHash) public
    VRFConsumerBaseV2(_VRFCoordinator)
    ERC721("Zerius v0", "ZV0")
    {
        tokenCounter = 0;
    }

    function mint() public returns (uint256) {
        uint256 newItemId = tokenCounter;
        tokenCounter++;
        _safeMint(owner, newItemId);
        return newItemId;
    }
}
