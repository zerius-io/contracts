// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import "../src/ZeriusRefuel.sol";


contract ZeriusRefuelScript is Script {

    function run() public {
        // ETHERIUM
//        address lzEndpoint = 0x66A71Dcef29A0fFBDBE3c6a460a3B5BC225Cd675;

        // ARBITRUM
//        address lzEndpoint = 0x3c2269811836af69497E5F486A85D7316753cf62;

        // OPTIMISM
//        address lzEndpoint = 0x3c2269811836af69497E5F486A85D7316753cf62;

        // POLYGON
//        address lzEndpoint = 0x3c2269811836af69497E5F486A85D7316753cf62;

        // BSC
//        address lzEndpoint = 0x3c2269811836af69497E5F486A85D7316753cf62;

        // AVALANCHE
//        address lzEndpoint = 0x3c2269811836af69497E5F486A85D7316753cf62;

        // BASE
//        address lzEndpoint = 0xb6319cC6c8c27A8F5dAF0dD3DF91EA35C4720dd7;

        // ZORA
        address lzEndpoint = 0xb6319cC6c8c27A8F5dAF0dD3DF91EA35C4720dd7;

        // SCROLL
//        address lzEndpoint = 0xb6319cC6c8c27A8F5dAF0dD3DF91EA35C4720dd7;

        // LINEA
//        address lzEndpoint = 0xb6319cC6c8c27A8F5dAF0dD3DF91EA35C4720dd7;

        // MOONBEAM
//        address lzEndpoint = 0x9740FF91F1985D8d2B71494aE1A2f723bb3Ed9E4;

        // CORE
//        address lzEndpoint = 0x9740FF91F1985D8d2B71494aE1A2f723bb3Ed9E4;

        // CELO
//        address lzEndpoint = 0x3A73033C0b1407574C76BdBAc67f126f6b4a9AA9;

        // HARMONY
//        address lzEndpoint = 0x9740FF91F1985D8d2B71494aE1A2f723bb3Ed9E4;

        // CANTO
//        address lzEndpoint = 0x9740FF91F1985D8d2B71494aE1A2f723bb3Ed9E4;

        // POLYGON ZkEVM
//        address lzEndpoint = 0x9740FF91F1985D8d2B71494aE1A2f723bb3Ed9E4;

        // FANTOM
//        address lzEndpoint = 0xb6319cC6c8c27A8F5dAF0dD3DF91EA35C4720dd7;

        // GNOSIS
//        address lzEndpoint = 0x9740FF91F1985D8d2B71494aE1A2f723bb3Ed9E4;

        // ARBITRUM NOVA
//        address lzEndpoint = 0x4EE2F9B7cf3A68966c370F3eb2C16613d3235245;

        // METIS
//        address lzEndpoint = 0x9740FF91F1985D8d2B71494aE1A2f723bb3Ed9E4;
        vm.broadcast();

        ZeriusRefuel refuel = new ZeriusRefuel(lzEndpoint);
    }
}
