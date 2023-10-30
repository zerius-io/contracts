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

    function run() public {
        // ETHERIUM
//        uint256 minGasToTransfer = 100000;
//        address lzEndpoint = 0x66A71Dcef29A0fFBDBE3c6a460a3B5BC225Cd675;
//        uint256 startMintId = 1;
//        uint256 endMintId = 500000;
//        uint256 mintFee = 0.000318706 ether;
//        uint256 bridgeFee = 0.000126957 ether;
//        address feeCollector = 0xBaF6B7ea2b1F4b42AC52095E95DACAa982f9FFcb;
//        uint256 referralEarningBips = 0;

        // ARBITRUM
//        uint256 minGasToTransfer = 100000;
//        address lzEndpoint = 0x3c2269811836af69497E5F486A85D7316753cf62;
//        uint256 startMintId = 1000001;
//        uint256 endMintId = 1500000;
//        uint256 mintFee = 0.00035 ether;
//        uint256 bridgeFee = 0.00016 ether;
//        address feeCollector = 0xBaF6B7ea2b1F4b42AC52095E95DACAa982f9FFcb;
//        uint256 referralEarningBips = 0;

        // OPTIMISM
//        uint256 minGasToTransfer = 100000;
//        address lzEndpoint = 0x3c2269811836af69497E5F486A85D7316753cf62;
//        uint256 startMintId = 1500001;
//        uint256 endMintId = 2000000;
//        uint256 mintFee = 0.00035 ether;
//        uint256 bridgeFee = 0.00016 ether;
//        address feeCollector = 0xBaF6B7ea2b1F4b42AC52095E95DACAa982f9FFcb;
//        uint256 referralEarningBips = 0;

        // POLYGON
//        uint256 minGasToTransfer = 100000;
//        address lzEndpoint = 0x3c2269811836af69497E5F486A85D7316753cf62;
//        uint256 startMintId = 2000001;
//        uint256 endMintId = 2500000;
//        uint256 mintFee = 1.06 ether;
//        uint256 bridgeFee = 0.485 ether;
//        address feeCollector = 0xBaF6B7ea2b1F4b42AC52095E95DACAa982f9FFcb;
//        uint256 referralEarningBips = 0;

        // BSC
//        uint256 minGasToTransfer = 100000;
//        address lzEndpoint = 0x3c2269811836af69497E5F486A85D7316753cf62;
//        uint256 startMintId = 2500001;
//        uint256 endMintId = 3000000;
//        uint256 mintFee = 0.00266 ether;
//        uint256 bridgeFee = 0.0012 ether;
//        address feeCollector = 0xBaF6B7ea2b1F4b42AC52095E95DACAa982f9FFcb;
//        uint256 referralEarningBips = 0;

        // AVALANCHE
//        uint256 minGasToTransfer = 100000;
//        address lzEndpoint = 0x3c2269811836af69497E5F486A85D7316753cf62;
//        uint256 startMintId = 3000001;
//        uint256 endMintId = 3500000;
//        uint256 mintFee = 0.0585 ether;
//        uint256 bridgeFee = 0.0266 ether;
//        address feeCollector = 0xBaF6B7ea2b1F4b42AC52095E95DACAa982f9FFcb;
//        uint256 referralEarningBips = 0;

        // BASE
//        uint256 minGasToTransfer = 100000;
//        address lzEndpoint = 0xb6319cC6c8c27A8F5dAF0dD3DF91EA35C4720dd7;
//        uint256 startMintId = 3500001;
//        uint256 endMintId = 4000000;
//        uint256 mintFee = 0.00035 ether;
//        uint256 bridgeFee = 0.00016 ether;
//        address feeCollector = 0xBaF6B7ea2b1F4b42AC52095E95DACAa982f9FFcb;
//        uint256 referralEarningBips = 0;

        // ZORA
//        uint256 minGasToTransfer = 100000;
//        address lzEndpoint = 0xb6319cC6c8c27A8F5dAF0dD3DF91EA35C4720dd7;
//        uint256 startMintId = 4000001;
//        uint256 endMintId = 4500000;
//        uint256 mintFee = 0.00035 ether;
//        uint256 bridgeFee = 0.00016 ether;
//        address feeCollector = 0xBaF6B7ea2b1F4b42AC52095E95DACAa982f9FFcb;
//        uint256 referralEarningBips = 0;

        // SCROLL
//        uint256 minGasToTransfer = 100000;
//        address lzEndpoint = 0xb6319cC6c8c27A8F5dAF0dD3DF91EA35C4720dd7;
//        uint256 startMintId = 4500001;
//        uint256 endMintId = 5000000;
//        uint256 mintFee = 0.00035 ether;
//        uint256 bridgeFee = 0.00016 ether;
//        address feeCollector = 0xBaF6B7ea2b1F4b42AC52095E95DACAa982f9FFcb;
//        uint256 referralEarningBips = 0;

        // LINEA
//        uint256 minGasToTransfer = 100000;
//        address lzEndpoint = 0xb6319cC6c8c27A8F5dAF0dD3DF91EA35C4720dd7;
//        uint256 startMintId = 5000001;
//        uint256 endMintId = 5500000;
//        uint256 mintFee = 0 ether;
//        uint256 bridgeFee = 0 ether;
//        address feeCollector = 0xBaF6B7ea2b1F4b42AC52095E95DACAa982f9FFcb;
//        uint256 referralEarningBips = 0;

        // MOONBEAM
//        uint256 minGasToTransfer = 100000;
//        address lzEndpoint = 0x9740FF91F1985D8d2B71494aE1A2f723bb3Ed9E4;
//        uint256 startMintId = 5500001;
//        uint256 endMintId = 6000000;
//        uint256 mintFee = 0 ether;
//        uint256 bridgeFee = 0 ether;
//        address feeCollector = 0xBaF6B7ea2b1F4b42AC52095E95DACAa982f9FFcb;
//        uint256 referralEarningBips = 0;

        // CORE
//        uint256 minGasToTransfer = 100000;
//        address lzEndpoint = 0x9740FF91F1985D8d2B71494aE1A2f723bb3Ed9E4;
//        uint256 startMintId = 6000001;
//        uint256 endMintId = 6500000;
//        uint256 mintFee = 0 ether;
//        uint256 bridgeFee = 0 ether;
//        address feeCollector = 0xBaF6B7ea2b1F4b42AC52095E95DACAa982f9FFcb;
//        uint256 referralEarningBips = 0;

        // CELO
//        uint256 minGasToTransfer = 100000;
//        address lzEndpoint = 0x3A73033C0b1407574C76BdBAc67f126f6b4a9AA9;
//        uint256 startMintId = 6500001;
//        uint256 endMintId = 7000000;
//        uint256 mintFee = 0 ether;
//        uint256 bridgeFee = 0 ether;
//        address feeCollector = 0xBaF6B7ea2b1F4b42AC52095E95DACAa982f9FFcb;
//        uint256 referralEarningBips = 0;

        // HARMONY
//        uint256 minGasToTransfer = 100000;
//        address lzEndpoint = 0x9740FF91F1985D8d2B71494aE1A2f723bb3Ed9E4;
//        uint256 startMintId = 7000001;
//        uint256 endMintId = 7500000;
//        uint256 mintFee = 0 ether;
//        uint256 bridgeFee = 0 ether;
//        address feeCollector = 0xBaF6B7ea2b1F4b42AC52095E95DACAa982f9FFcb;
//        uint256 referralEarningBips = 0;

        // CANTO
//        uint256 minGasToTransfer = 100000;
//        address lzEndpoint = 0x9740FF91F1985D8d2B71494aE1A2f723bb3Ed9E4;
//        uint256 startMintId = 7500001;
//        uint256 endMintId = 8000000;
//        uint256 mintFee = 0 ether;
//        uint256 bridgeFee = 0 ether;
//        address feeCollector = 0xBaF6B7ea2b1F4b42AC52095E95DACAa982f9FFcb;
//        uint256 referralEarningBips = 0;

        // POLYGON ZkEVM
//        uint256 minGasToTransfer = 100000;
//        address lzEndpoint = 0x9740FF91F1985D8d2B71494aE1A2f723bb3Ed9E4;
//        uint256 startMintId = 8000001;
//        uint256 endMintId = 8500000;
//        uint256 mintFee = 0 ether;
//        uint256 bridgeFee = 0 ether;
//        address feeCollector = 0xBaF6B7ea2b1F4b42AC52095E95DACAa982f9FFcb;
//        uint256 referralEarningBips = 0;

        // FANTOM
//        uint256 minGasToTransfer = 100000;
//        address lzEndpoint = 0xb6319cC6c8c27A8F5dAF0dD3DF91EA35C4720dd7;
//        uint256 startMintId = 8500001;
//        uint256 endMintId = 9000000;
//        uint256 mintFee = 0 ether;
//        uint256 bridgeFee = 0 ether;
//        address feeCollector = 0xBaF6B7ea2b1F4b42AC52095E95DACAa982f9FFcb;
//        uint256 referralEarningBips = 0;

        // GNOSIS
//        uint256 minGasToTransfer = 100000;
//        address lzEndpoint = 0x9740FF91F1985D8d2B71494aE1A2f723bb3Ed9E4;
//        uint256 startMintId = 9000001;
//        uint256 endMintId = 9500000;
//        uint256 mintFee = 0 ether;
//        uint256 bridgeFee = 0 ether;
//        address feeCollector = 0xBaF6B7ea2b1F4b42AC52095E95DACAa982f9FFcb;
//        uint256 referralEarningBips = 0;

        // ARBITRUM NOVA
        uint256 minGasToTransfer = 100000;
        address lzEndpoint = 0x4EE2F9B7cf3A68966c370F3eb2C16613d3235245;
        uint256 startMintId = 9500001;
        uint256 endMintId = 10000000;
        uint256 mintFee = 0 ether;
        uint256 bridgeFee = 0 ether;
        address feeCollector = 0xBaF6B7ea2b1F4b42AC52095E95DACAa982f9FFcb;
        uint256 referralEarningBips = 0;

        // METIS
//        uint256 minGasToTransfer = 100000;
//        address lzEndpoint = 0x9740FF91F1985D8d2B71494aE1A2f723bb3Ed9E4;
//        uint256 startMintId = 10000001;
//        uint256 endMintId = 10500000;
//        uint256 mintFee = 0 ether;
//        uint256 bridgeFee = 0 ether;
//        address feeCollector = 0xBaF6B7ea2b1F4b42AC52095E95DACAa982f9FFcb;
//        uint256 referralEarningBips = 0;

        vm.broadcast();

        ZeriusONFT721 zerius = new ZeriusONFT721(
            minGasToTransfer,
            lzEndpoint,
            startMintId,
            endMintId,
            mintFee,
            bridgeFee,
            feeCollector,
            referralEarningBips
        );
    }
}
