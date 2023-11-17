// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console2} from "forge-std/Script.sol";
import "../src/ZeriusONFT721.sol";

contract MintAndBridgeScript is Script {

    uint16 private ARBITRUM = 10143;
    uint16 private ZKSYNC = 10165;
    uint16 private MUMBAI = 10109;

    function run() public {
        address from = 0xdF2f595541307c31F879A17E7C0BBeaca6375634;
        bytes memory to = abi.encodePacked(from);
        address addr = 0xEB22C3e221080eAD305CAE5f37F0753970d973Cd;
        uint16 dstChainId = 110;

        ZeriusONFT721 zerius = ZeriusONFT721(addr);

        vm.startBroadcast();

        zerius.mint{value: zerius.mintFee()}();
        uint256 tokenId = zerius.tokenCounter() - 1;

        uint16 adapterV = 1;
        uint256 value = zerius.minDstGasLookup(dstChainId, 1);
        bytes memory adapterParams = abi.encodePacked(adapterV, value);
        (uint256 nativeFee, uint256 zroFee) = zerius.estimateSendFee(
            dstChainId,
            to,
            tokenId,
            false,
            adapterParams
        );

        zerius.sendFrom{value: nativeFee}(
            from,
            dstChainId,
            to,
            tokenId,
            payable(from),
            address(0),
            adapterParams
        );

        vm.stopBroadcast();
    }
}

contract SetBaseURIScript is Script {

    function run() public {
        address addr = 0x1acCF58b9A5367Bf2c73A683Cb617800ceba6f09;
        ZeriusONFT721 zerius = ZeriusONFT721(addr);

        vm.startBroadcast();

        zerius.setTokenBaseURI("https://zerius.mypinata.cloud/ipfs/QmNQLvTeZVyAjStrAmJxr1RU359ZgFtXECD6z37HsoGBwk/", ".png");

        zerius.mint{value: zerius.mintFee()}();
        uint256 tokenId = zerius.tokenCounter() - 1;

        string memory tokenURI = zerius.tokenURI(tokenId);

        vm.stopBroadcast();

        console2.log(tokenURI);
    }
}

contract ClaimFeeEarningsScript is Script {
    function run() public {
        address addr = 0x1acCF58b9A5367Bf2c73A683Cb617800ceba6f09;
        ZeriusONFT721 zerius = ZeriusONFT721(addr);

        vm.startBroadcast();

        zerius.setMintFee(360000000000000);
        zerius.mint{value: zerius.mintFee()}();

        zerius.claimFeeEarnings();

        vm.stopBroadcast();
    }
}

contract ClaimReferralEarningsScript is Script {
    function run() public {
        address referrer = 0xB9d364158Dc1B5E856402De54F18A3d8b7dAa80F;
        address addr = 0x1acCF58b9A5367Bf2c73A683Cb617800ceba6f09;
        ZeriusONFT721 zerius = ZeriusONFT721(addr);

        vm.startBroadcast();

        zerius.setReferralEarningBips(5000);
        zerius.mint{value: zerius.mintFee()}(referrer);

        zerius.claimReferrerEarnings();

        vm.stopBroadcast();
    }
}
