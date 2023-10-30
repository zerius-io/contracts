// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console2} from "forge-std/Script.sol";
import "../src/ZeriusONFT721.sol";

contract LinkONFTContractsScript is Script {
    mapping(uint16 => address) private contracts;
    mapping(uint16 => uint256) private minDstGas;
    mapping(uint256 => uint16) private lzIds;
    uint256 private chainsCount = 11;

    function setUp() public {
//        uint16 ethereum = 101;
//        uint16 arbitrum = 110;
//        uint16 optimism = 111;
//        uint16 polygon = 109;
//        uint16 bsc = 102;
//        uint16 avalanche = 106;
//        uint16 base = 184;
//        uint16 zora = 195;
//        uint16 scroll = 214;
//        uint16 zksync = 165;
        uint16 linea = 183;
        uint16 nova = 175;
        uint16 metis = 151;
        uint16 moonbeam = 126;
        uint16 polygonZkevm = 158;
        uint16 core = 153;
        uint16 celo = 125;
        uint16 harmony = 116;
        uint16 canto = 159;
        uint16 fantom = 112;
        uint16 gnosis = 145;

//        lzIds[0] = ethereum;
//        lzIds[1] = arbitrum;
//        lzIds[2] = optimism;
//        lzIds[3] = polygon;
//        lzIds[4] = bsc;
//        lzIds[5] = avalanche;
//        lzIds[6] = base;
//        lzIds[7] = zora;
//        lzIds[0] = scroll;
//        lzIds[7] = zksync;
        lzIds[0] = linea;
        lzIds[1] = nova;
        lzIds[2] = metis;
        lzIds[3] = moonbeam;
        lzIds[4] = polygonZkevm;
        lzIds[5] = core;
        lzIds[6] = celo;
        lzIds[7] = harmony;
        lzIds[8] = canto;
        lzIds[9] = fantom;
        lzIds[10] = gnosis;

//        contracts[ethereum] = 0x178608fFe2Cca5d36f3Fc6e69426c4D3A5A74A41;
//        contracts[arbitrum] = 0x250c34D06857b9C0A036d44F86d2c1Abe514B3Da;
//        contracts[optimism] = 0x178608fFe2Cca5d36f3Fc6e69426c4D3A5A74A41;
//        contracts[polygon] = 0x178608fFe2Cca5d36f3Fc6e69426c4D3A5A74A41;
//        contracts[bsc] = 0x250c34D06857b9C0A036d44F86d2c1Abe514B3Da;
//        contracts[avalanche] = 0x178608fFe2Cca5d36f3Fc6e69426c4D3A5A74A41;
//        contracts[base] = 0x178608fFe2Cca5d36f3Fc6e69426c4D3A5A74A41;
//        contracts[zora] = 0x178608fFe2Cca5d36f3Fc6e69426c4D3A5A74A41;
//        contracts[scroll] = 0xEB22C3e221080eAD305CAE5f37F0753970d973Cd;
//        contracts[zksync] = 0x7dA50bD0fb3C2E868069d9271A2aeb7eD943c2D6;
        contracts[linea] = 0x5188368a92B49F30f4Cf9bEF64635bCf8459c7A7;
        contracts[nova] = 0x5188368a92B49F30f4Cf9bEF64635bCf8459c7A7;
        contracts[metis] = 0x5188368a92B49F30f4Cf9bEF64635bCf8459c7A7;
        contracts[moonbeam] = 0x4c5AeDA35d8F0F7b67d6EB547eAB1df75aA23Eaf;
        contracts[polygonZkevm] = 0x4c5AeDA35d8F0F7b67d6EB547eAB1df75aA23Eaf;
        contracts[core] = 0x5188368a92B49F30f4Cf9bEF64635bCf8459c7A7;
        contracts[celo] = 0x4c5AeDA35d8F0F7b67d6EB547eAB1df75aA23Eaf;
        contracts[harmony] = 0x5188368a92B49F30f4Cf9bEF64635bCf8459c7A7;
        contracts[canto] = 0x5188368a92B49F30f4Cf9bEF64635bCf8459c7A7;
        contracts[fantom] = 0x5188368a92B49F30f4Cf9bEF64635bCf8459c7A7;
        contracts[gnosis] = 0x5188368a92B49F30f4Cf9bEF64635bCf8459c7A7;

//        minDstGas[ethereum] = 300000;
//        minDstGas[arbitrum] = 250000;
//        minDstGas[optimism] = 250000;
//        minDstGas[polygon] = 250000;
//        minDstGas[bsc] = 250000;
//        minDstGas[avalanche] = 250000;
//        minDstGas[base] = 250000;
//        minDstGas[zora] = 250000;
//        minDstGas[scroll] = 250000;
//        minDstGas[zksync] = 2000000;
        minDstGas[linea] = 250000;
        minDstGas[nova] = 250000;
        minDstGas[metis] = 250000;
        minDstGas[moonbeam] = 400000;
        minDstGas[polygonZkevm] = 250000;
        minDstGas[core] = 250000;
        minDstGas[celo] = 250000;
        minDstGas[harmony] = 250000;
        minDstGas[canto] = 250000;
        minDstGas[fantom] = 250000;
        minDstGas[gnosis] = 250000;
    }

    function run() public {
        address addr = 0xEB22C3e221080eAD305CAE5f37F0753970d973Cd;
        uint16 lzId = 214;
        ZeriusONFT721 zerius = ZeriusONFT721(addr);

        vm.startBroadcast();
//        zerius.mint{value: zerius.mintFee()}();
//        zerius.mint{value: zerius.mintFee()}();
//        zerius.mint{value: zerius.mintFee()}();
//        zerius.mint{value: zerius.mintFee()}();
//        zerius.mint{value: zerius.mintFee()}();

//        zerius.setTokenBaseURI("https://zerius.mypinata.cloud/ipfs/Qme7km7vLAcNS4FLnJBuG8qwUJJxvDnyRV4TjYngU1oCoG/", ".png");

        for (uint256 i = 0; i < chainsCount; i++) {
            uint16 lz = lzIds[i];
            if (lzId != lz) {
                if (zerius.minDstGasLookup(lz, 1) == 0) {
                    uint256 dstGas = minDstGas[lz];
                    zerius.setMinDstGas(lz, 1, dstGas);
                }

                if (zerius.trustedRemoteLookup(lz).length == 0) {
                    address dstAddr = contracts[lz];
                    bytes memory trusted = abi.encodePacked(dstAddr, addr);
                    zerius.setTrustedRemote(lz, trusted);
                }
            }
        }

        vm.stopBroadcast();
    }
}
