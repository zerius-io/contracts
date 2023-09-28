// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import "../src/ZeriusONFT721.sol";

contract ZeriusONFT721Script is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
        ZeriusONFT721 zerius = new ZeriusONFT721(
            100000,
            0xf69186dfBa60DdB133E91E9A4B5673624293d8F8,
            0,
            1000,
            0,
            0,
            0x7988ba7A5C1993f40271bA4463BF8043d5cfaa0C
        );
    }
}
