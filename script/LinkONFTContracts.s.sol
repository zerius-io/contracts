// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console2} from "forge-std/Script.sol";
import "../src/ZeriusONFT721.sol";
import "../src/ZeriusRefuel.sol";

contract LinkONFTContractsScript is Script {
    mapping(uint16 => address) private contracts;
    mapping(uint16 => uint256) private minDstGas;
    mapping(uint256 => uint16) private lzIds;
    uint256 private chainsCount = 1;

    struct ChainToConnect {
        uint16 lzId;
        address contractAddress;
        uint256 minDstGas;
    }

    ChainToConnect[] private chainsToConnect;


    // REFUEL
    ChainToConnect private ETHEREUM = ChainToConnect(101, 0x178608fFe2Cca5d36f3Fc6e69426c4D3A5A74A41, 300000); // ethereum
    ChainToConnect private ARBITRUM = ChainToConnect(110, 0x412aea168aDd34361aFEf6a2e3FC01928Fba1248, 200000); // arbitrum
    ChainToConnect private OPTIMISM = ChainToConnect(111, 0x2076BDd52Af431ba0E5411b3dd9B5eeDa31BB9Eb, 200000); // optimism
    ChainToConnect private POLYGON = ChainToConnect(109, 0x2ef766b59e4603250265EcC468cF38a6a00b84b3, 250000); // polygon
    ChainToConnect private BSC = ChainToConnect(102, 0x5B209E7c81DEaad0ffb8b76b696dBb4633A318CD, 250000); // bsc
    ChainToConnect private AVALANCHE = ChainToConnect(106, 0x5B209E7c81DEaad0ffb8b76b696dBb4633A318CD, 250000); // avalanche
    ChainToConnect private BASE = ChainToConnect(184, 0x9415AD63EdF2e0de7D8B9D8FeE4b939dd1e52F2C, 250000);
    ChainToConnect private ZORA = ChainToConnect(195, 0x1fe2c567169d39CCc5299727FfAC96362b2Ab90E, 250000); // zora
    ChainToConnect private SCROLL = ChainToConnect(214, 0xEB22C3e221080eAD305CAE5f37F0753970d973Cd, 250000); // scroll
    ChainToConnect private ZKSYNC = ChainToConnect(165, 0x7dA50bD0fb3C2E868069d9271A2aeb7eD943c2D6, 2000000); // zkSync
    ChainToConnect private LINEA = ChainToConnect(183, 0x5188368a92B49F30f4Cf9bEF64635bCf8459c7A7, 250000); // linea
    ChainToConnect private NOVA = ChainToConnect(175, 0x5188368a92B49F30f4Cf9bEF64635bCf8459c7A7, 250000); // nova
    ChainToConnect private METIS = ChainToConnect(151, 0x5188368a92B49F30f4Cf9bEF64635bCf8459c7A7, 250000); // metis
    ChainToConnect private MOONBEAM = ChainToConnect(126, 0x4c5AeDA35d8F0F7b67d6EB547eAB1df75aA23Eaf, 400000); // moonbeam
    ChainToConnect private POLYGONZKEVM = ChainToConnect(158, 0x4c5AeDA35d8F0F7b67d6EB547eAB1df75aA23Eaf, 250000); // polygonZkEvm
    ChainToConnect private CORE = ChainToConnect(153, 0x5188368a92B49F30f4Cf9bEF64635bCf8459c7A7, 250000); // core
    ChainToConnect private CELO = ChainToConnect(125, 0x4c5AeDA35d8F0F7b67d6EB547eAB1df75aA23Eaf, 250000); // celo
    ChainToConnect private HARMONY = ChainToConnect(116, 0x5188368a92B49F30f4Cf9bEF64635bCf8459c7A7, 250000); // harmony
    ChainToConnect private CANTO = ChainToConnect(159, 0x5188368a92B49F30f4Cf9bEF64635bCf8459c7A7, 250000); // canto
    ChainToConnect private FANTOM = ChainToConnect(112, 0x5188368a92B49F30f4Cf9bEF64635bCf8459c7A7, 250000); // fantom
    ChainToConnect private GNOSIS = ChainToConnect(145, 0x5188368a92B49F30f4Cf9bEF64635bCf8459c7A7, 250000); // gnosis


    ChainToConnect private selectedChain = ARBITRUM;


    function setUp() public {
//        chainsToConnect.push(ChainToConnect(101, 0x178608fFe2Cca5d36f3Fc6e69426c4D3A5A74A41, 300000)); // ethereum
//        chainsToConnect.push(ChainToConnect(110, 0xEf916A89438607c77366f6f0c469CF80bcCA5511, 200000)); // arbitrum
//        chainsToConnect.push(ChainToConnect(111, 0xE8bD859e64A769dA99A882fB9F6a403Fd61C0A36, 200000)); // optimism
//        chainsToConnect.push(ChainToConnect(109, 0x178608fFe2Cca5d36f3Fc6e69426c4D3A5A74A41, 250000)); // polygon
//        chainsToConnect.push(ChainToConnect(102, 0x250c34D06857b9C0A036d44F86d2c1Abe514B3Da, 250000)); // bsc
//        chainsToConnect.push(ChainToConnect(106, 0x178608fFe2Cca5d36f3Fc6e69426c4D3A5A74A41, 250000)); // avalanche
//        chainsToConnect.push(ChainToConnect(184, 0xFB0fc5C1B81deb666d12287E0bA4399faDD7790E, 250000)); // base
//        chainsToConnect.push(ChainToConnect(195, 0x178608fFe2Cca5d36f3Fc6e69426c4D3A5A74A41, 250000)); // zora
//        chainsToConnect.push(ChainToConnect(214, 0xEB22C3e221080eAD305CAE5f37F0753970d973Cd, 250000)); // scroll
//        chainsToConnect.push(ChainToConnect(165, 0x7dA50bD0fb3C2E868069d9271A2aeb7eD943c2D6, 2000000)); // zkSync
//        chainsToConnect.push(ChainToConnect(183, 0x5188368a92B49F30f4Cf9bEF64635bCf8459c7A7, 250000)); // linea
//        chainsToConnect.push(ChainToConnect(175, 0x5188368a92B49F30f4Cf9bEF64635bCf8459c7A7, 250000)); // nova
//        chainsToConnect.push(ChainToConnect(151, 0x5188368a92B49F30f4Cf9bEF64635bCf8459c7A7, 250000)); // metis
//        chainsToConnect.push(ChainToConnect(126, 0x4c5AeDA35d8F0F7b67d6EB547eAB1df75aA23Eaf, 400000)); // moonbeam
//        chainsToConnect.push(ChainToConnect(158, 0x4c5AeDA35d8F0F7b67d6EB547eAB1df75aA23Eaf, 250000)); // polygonZkEvm
//        chainsToConnect.push(ChainToConnect(153, 0x5188368a92B49F30f4Cf9bEF64635bCf8459c7A7, 250000)); // core
//        chainsToConnect.push(ChainToConnect(125, 0x4c5AeDA35d8F0F7b67d6EB547eAB1df75aA23Eaf, 250000)); // celo
//        chainsToConnect.push(ChainToConnect(116, 0x5188368a92B49F30f4Cf9bEF64635bCf8459c7A7, 250000)); // harmony
//        chainsToConnect.push(ChainToConnect(159, 0x5188368a92B49F30f4Cf9bEF64635bCf8459c7A7, 250000)); // canto
//        chainsToConnect.push(ChainToConnect(112, 0x5188368a92B49F30f4Cf9bEF64635bCf8459c7A7, 250000)); // fantom
//        chainsToConnect.push(ChainToConnect(145, 0x5188368a92B49F30f4Cf9bEF64635bCf8459c7A7, 250000)); // gnosis

        // REFUEL CONTRACT ADDRESSES
//        chainsToConnect.push(ETHEREUM); // ethereum
//        chainsToConnect.push(ARBITRUM); // arbitrum
        chainsToConnect.push(OPTIMISM); // optimism
//        chainsToConnect.push(POLYGON); // polygon
//        chainsToConnect.push(BSC); // bsc
//        chainsToConnect.push(AVALANCHE); // avalanche
//        chainsToConnect.push(BASE); // base
//        chainsToConnect.push(ZORA); // zora
//        chainsToConnect.push(SCROLL); // scroll
//        chainsToConnect.push(ZKSYNC); // zkSync
//        chainsToConnect.push(LINEA); // linea
//        chainsToConnect.push(NOVA); // nova
//        chainsToConnect.push(METIS); // metis
//        chainsToConnect.push(MOONBEAM); // moonbeam
//        chainsToConnect.push(POLYGONZKEVM); // polygonZkEvm
//        chainsToConnect.push(CORE); // core
//        chainsToConnect.push(CELO); // celo
//        chainsToConnect.push(HARMONY); // harmony
//        chainsToConnect.push(CANTO); // canto
//        chainsToConnect.push(FANTOM); // fantom
//        chainsToConnect.push(GNOSIS); // gnosis
    }

    function run() public {
        ZeriusRefuel zerius = ZeriusRefuel(selectedChain.contractAddress);

        vm.startBroadcast();


        for (uint256 i = 0; i < chainsToConnect.length; i++) {
            ChainToConnect memory chainToConnect = chainsToConnect[i];

            if (selectedChain.lzId != chainToConnect.lzId) {

                if (zerius.minDstGasLookup(chainToConnect.lzId, 0) == 0) {
                    zerius.setMinDstGas(chainToConnect.lzId, 0, chainToConnect.minDstGas);
                }

                if (zerius.trustedRemoteLookup(chainToConnect.lzId).length == 0) {
                    address dstAddr = chainToConnect.contractAddress;
                    bytes memory trusted = abi.encodePacked(dstAddr, selectedChain.contractAddress);
                    zerius.setTrustedRemote(chainToConnect.lzId, trusted);
                }
            }
        }

        vm.stopBroadcast();
    }
}

//        uint16 lz = chainsToConnect[0].lzId;
//        uint16 lzVersion = 2;
//        uint256 gasLimitExtra = 1200000000000000;
//        address walletAddress = msg.sender;
//
//        bytes memory adapterParams = abi.encodePacked(
//            lzVersion,
//            chainsToConnect[0].minDstGas,
//            gasLimitExtra,
//            walletAddress
//        );
//        zerius.refuel{gas: 1627800, value: 2200000000000000}(lz, abi.encodePacked(chainsToConnect[0].contractAddress), adapterParams);


//        zerius.mint{value: zerius.mintFee()}();
//        zerius.mint{value: zerius.mintFee()}();
//        zerius.mint{value: zerius.mintFee()}();
//        zerius.mint{value: zerius.mintFee()}();
//        zerius.mint{value: zerius.mintFee()}(); //        zerius.setTokenBaseURI("https://zerius.mypinata.cloud/ipfs/Qme7km7vLAcNS4FLnJBuG8qwUJJxvDnyRV4TjYngU1oCoG/", ".png");

