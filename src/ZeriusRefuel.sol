// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@layerzerolabs/contracts/lzApp/NonblockingLzApp.sol";

contract ZeriusRefuel is NonblockingLzApp {

    uint256 private fee;

    uint16 public constant FUNCTION_TYPE_SEND = 0;

    constructor(address _lzEndpoint) NonblockingLzApp(_lzEndpoint) {}

    function _nonblockingLzReceive(uint16, bytes memory, uint64, bytes memory) internal virtual override {}

    function estimateSendFee(
        uint16 _dstChainId,
        bytes memory payload,
        bytes memory _adapterParams
    ) public view virtual returns (uint nativeFee, uint zroFee) {
        (nativeFee, zroFee) = lzEndpoint.estimateFees(_dstChainId, address(this), payload, false, _adapterParams);
        nativeFee += fee;
        return (nativeFee, zroFee);
    }

    function refuel(
        uint16 _dstChainId,
        bytes memory _toAddress,
        bytes memory _adapterParams
    ) external payable virtual {
        _checkGasLimit(_dstChainId, FUNCTION_TYPE_SEND, _adapterParams, 0);

        (uint nativeFee,) = estimateSendFee(_dstChainId, _toAddress, _adapterParams);
        require(msg.value >= nativeFee, "Not enough gas to send");

        _lzSend(_dstChainId, _toAddress, payable(0x0), address(0x0), _adapterParams, nativeFee - fee);
    }

    function setFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    function getFee() external view returns (uint256) {
        return fee;
    }

    function withdraw() external payable onlyOwner {
        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }
}

