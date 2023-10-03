// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import "../src/ZeriusONFT721.sol";

/**
* @author Zerius
* @title ZeriusONFT721Script
* @notice Deploy script for {ZeriusONFT721}
*/
contract ZeriusONFT721Script is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();

        uint256 minGasToTransfer = 100000;
        address lzEndpoint = 0xf69186dfBa60DdB133E91E9A4B5673624293d8F8;
        uint256 startMintId = 0;
        uint256 endMintId = 1000;
        uint256 mintFee = 0;
        uint256 bridgeFee = 0;
        address feeCollector = 0x7988ba7A5C1993f40271bA4463BF8043d5cfaa0C;

        ZeriusONFT721 zerius = new ZeriusONFT721(
            minGasToTransfer,
            lzEndpoint,
            startMintId,
            endMintId,
            mintFee,
            bridgeFee,
            feeCollector
        );
    }
}
