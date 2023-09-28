// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@layerzerolabs/contracts/token/onft/ONFT721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
* @title ZeriusONFT721
* @author polypox
*/
contract ZeriusONFT721 is ONFT721, ERC721Enumerable {

    uint8 public constant ERROR_TOKEN_URI_LOCKED = 1;
    uint8 public constant ERROR_MINT_EXCEEDS_LIMIT = 2;
    uint8 public constant ERROR_MINT_INVALID_FEE = 3;
    uint8 public constant ERROR_INVALID_TOKEN_ID = 4;
    uint8 public constant ERROR_INVALID_COLLECTOR_ADDRESS = 5;
    uint8 public constant ERROR_NOTHING_TO_CLAIM = 6;
    uint8 public constant ERROR_NOT_FEE_COLLECTOR = 7;
    uint8 public constant ERROR_REFERRAL_BIPS_TOO_HIGH = 8;
    uint8 public constant ERROR_INVALID_REFERER = 9;

    error ZeriusONFT721_CoreError(uint256 errorCode);

    event MintFeeChanged(uint256 indexed oldMintFee, uint256 indexed newMintFee);
    event BridgeFeeChanged(uint256 indexed oldBridgeFee, uint256 indexed newBridgeFee);
    event ReferralEarningBipsChanged(uint256 indexed oldReferralEarningBips, uint256 indexed newReferralEarningBips);
    event EarningBipsForReferrerChanged(address indexed referrer, uint256 newEraningBips);
    event FeeCollectorChanged(address indexed oldFeeCollector, address indexed newFeeCollector);
    event TokenURIChanged(string indexed oldTokenURI, string indexed newTokenURI);
    event TokenURILocked();

    event ONFTMinted(
        address indexed minter,
        uint256 indexed itemId,
        uint256 feeEarnings,
        address indexed referrer,
        uint256 referrerEarnings
    );

    event BridgeFeeEarned(
        address indexed from,
        uint16 indexed dstChainId,
        uint256 amount
    );

    event FeeEarningsClaimed(address indexed collector, uint256 claimedAmount);
    event ReferrerEarningsClaimed(address indexed referrer, uint256 claimedAmount);

    uint256 public constant ONE_HUNDRED_PERCENT = 10000; // 100%
    uint256 public constant FIFTY_PERCENT = 5000; // 50%
    uint256 public constant DENOMINATOR = ONE_HUNDRED_PERCENT; // 100%

    uint256 public immutable startMintId;
    uint256 public immutable maxMintId;

    uint256 public mintFee;
    uint256 public bridgeFee;
    address public feeCollector;

    uint256 public referralEarningBips;
    mapping (address => uint256) public referrersEarningBips;
    mapping (address => uint256) public referredTransactionsCount;
    mapping (address => uint256) public referrersEarnedAmount;
    mapping (address => uint256) public referrersClaimedAmount;

    uint256 public feeEarnedAmount;
    uint256 public feeClaimedAmount;

    uint256 public tokenCounter;

    string private _tokenBaseURI;
    bool public tokenBaseURILocked;

    modifier onlyFeeCollector() {
        _checkFeeCollector();
        _;
    }

    constructor(
        uint256 _minGasToTransfer,
        address _lzEndpoint,
        uint256 _startMintId,
        uint256 _endMintId,
        uint256 _mintFee,
        uint256 _bridgeFee,
        address _feeCollector
    ) ONFT721("ZeriusNFT V0", "ZVO", _minGasToTransfer, _lzEndpoint) {
        startMintId = _startMintId;
        maxMintId = _endMintId;
        mintFee = _mintFee;
        bridgeFee = _bridgeFee;
        feeCollector = _feeCollector;
        tokenCounter = _startMintId;
    }

    function setMintFee(uint256 _mintFee) external onlyOwner {
        uint256 oldMintFee = mintFee;
        mintFee = _mintFee;
        emit MintFeeChanged(oldMintFee, _mintFee);
    }

    function setBridgeFee(uint256 _bridgeFee) external onlyOwner {
        uint256 oldBridgeFee = bridgeFee;
        bridgeFee = _bridgeFee;
        emit BridgeFeeChanged(oldBridgeFee, _bridgeFee);
    }

    function setReferralEarningBips(uint256 _referralEarninBips) external onlyOwner {
        _validate(_referralEarninBips <= FIFTY_PERCENT, ERROR_REFERRAL_BIPS_TOO_HIGH);
        uint256 oldReferralEarningsShareBips = referralEarningBips;
        referralEarningBips = _referralEarninBips;
        emit ReferralEarningBipsChanged(oldReferralEarningsShareBips, _referralEarninBips);
    }

    function setEarningBipsForReferrer(
        address referrer,
        uint256 earningBips
    ) external onlyOwner {
        _validate(earningBips <= ONE_HUNDRED_PERCENT, ERROR_REFERRAL_BIPS_TOO_HIGH);
        referrersEarningBips[referrer] = earningBips;
        emit EarningBipsForReferrerChanged(referrer, earningBips);
    }

    function setFeeCollector(address _feeCollector) external onlyOwner {
        _validate(_feeCollector != address(0), ERROR_INVALID_COLLECTOR_ADDRESS);
        address oldFeeCollector = feeCollector;
        feeCollector = _feeCollector;
        emit FeeCollectorChanged(oldFeeCollector, _feeCollector);
    }

    function setTokenBaseURI(string calldata _newTokenBaseURI) external onlyOwner {
        _validate(!tokenBaseURILocked, ERROR_TOKEN_URI_LOCKED);
        string memory oldTokenBaseURI = _tokenBaseURI;
        _tokenBaseURI = _newTokenBaseURI;
        emit TokenURIChanged(oldTokenBaseURI, _newTokenBaseURI);
    }

    function lockTokenBaseURI() external onlyOwner {
        _validate(!tokenBaseURILocked, ERROR_TOKEN_URI_LOCKED);
        tokenBaseURILocked = true;
        emit TokenURILocked();
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _validate(_exists(tokenId), ERROR_INVALID_TOKEN_ID);
        return string(abi.encodePacked(_tokenBaseURI, "?id=", Strings.toString(tokenId)));
    }

    function mint() external payable nonReentrant {
        uint256 newItemId = tokenCounter;
        uint256 feeEarnings = mintFee;

        _validate(newItemId < maxMintId, ERROR_MINT_EXCEEDS_LIMIT);
        _validate(msg.value == feeEarnings, ERROR_MINT_INVALID_FEE);

        ++tokenCounter;

        feeEarnedAmount += feeEarnings;

        _safeMint(_msgSender(), newItemId);
        emit ONFTMinted(
            _msgSender(),
            newItemId,
            feeEarnings,
            address(0),
            0
        );
    }

    function mint(address referrer) public payable nonReentrant {
        uint256 newItemId = tokenCounter;
        uint256 _mintFee = mintFee;

        _validate(newItemId < maxMintId, ERROR_MINT_EXCEEDS_LIMIT);
        _validate(msg.value == _mintFee, ERROR_MINT_INVALID_FEE);
        _validate(referrer != _msgSender() && referrer != address(0), ERROR_INVALID_REFERER);

        ++tokenCounter;

        uint256 referrerBips = referrersEarningBips[referrer];
        uint256 referrerShareBips = referrerBips == 0
            ? referralEarningBips
            : referrerBips;
        uint256 referrerEarnings = (_mintFee * referrerShareBips) / DENOMINATOR;
        uint256 feeEarnings = _mintFee - referrerEarnings;

        referrersEarnedAmount[referrer] += referrerEarnings;
        ++referredTransactionsCount[referrer];

        feeEarnedAmount += feeEarnings;

        _safeMint(_msgSender(), newItemId);
        emit ONFTMinted(
            _msgSender(),
            newItemId,
            feeEarnings,
            referrer,
            referrerEarnings
        );
    }

    function estimateSendFee(
        uint16 _dstChainId,
        bytes memory _toAddress,
        uint _tokenId,
        bool _useZro,
        bytes memory _adapterParams
    ) public view virtual override(ONFT721Core, IONFT721Core) returns (uint nativeFee, uint zroFee) {
        return this.estimateSendBatchFee(
            _dstChainId,
            _toAddress,
            _toSingletonArray(_tokenId),
            _useZro,
            _adapterParams
        );
    }

    function estimateSendBatchFee(
        uint16 _dstChainId,
        bytes memory _toAddress,
        uint[] memory _tokenIds,
        bool _useZro,
        bytes memory _adapterParams
    ) public view override(ONFT721Core, IONFT721Core) returns (uint256 nativeFee, uint256 zroFee) {
        (nativeFee, zroFee) = super.estimateSendBatchFee(
            _dstChainId,
            _toAddress,
            _tokenIds,
            _useZro,
            _adapterParams
        );
        nativeFee += bridgeFee;
        return (nativeFee, zroFee);
    }

    function sendFrom(
        address _from,
        uint16 _dstChainId,
        bytes memory _toAddress,
        uint _tokenId,
        address payable _refundAddress,
        address _zroPaymentAddress,
        bytes memory _adapterParams
    ) public payable override(ONFT721Core, IONFT721Core) {
        _handleSend(
            _from,
            _dstChainId,
            _toAddress,
            _toSingletonArray(_tokenId),
            _refundAddress,
            _zroPaymentAddress,
            _adapterParams
        );
    }

    function sendBatchFrom(
        address _from,
        uint16 _dstChainId,
        bytes memory _toAddress,
        uint[] memory _tokenIds,
        address payable _refundAddress,
        address _zroPaymentAddress,
        bytes memory _adapterParams
    ) public payable virtual override(ONFT721Core, IONFT721Core) {
        _handleSend(
            _from,
            _dstChainId,
            _toAddress,
            _tokenIds,
            _refundAddress,
            _zroPaymentAddress,
            _adapterParams
        );
    }

    function _handleSend(
        address _from,
        uint16 _dstChainId,
        bytes memory _toAddress,
        uint[] memory _tokenIds,
        address payable _refundAddress,
        address _zroPaymentAddress,
        bytes memory _adapterParams
    ) private {
        uint256 _bridgeFee = bridgeFee;
        uint256 _nativeFee = msg.value - _bridgeFee;

        feeEarnedAmount += _bridgeFee;

        _send(
            _from,
            _dstChainId,
            _toAddress,
            _tokenIds,
            _refundAddress,
            _zroPaymentAddress,
            _adapterParams,
            _nativeFee
        );

        emit BridgeFeeEarned(_from, _dstChainId, _bridgeFee);
    }

    function _send(
        address _from,
        uint16 _dstChainId,
        bytes memory _toAddress,
        uint[] memory _tokenIds,
        address payable _refundAddress,
        address _zroPaymentAddress,
        bytes memory _adapterParams,
        uint256 _nativeFee
    ) internal virtual {
        // allow 1 by default
        require(_tokenIds.length > 0, "tokenIds[] is empty");
        require(
            _tokenIds.length == 1 ||
                _tokenIds.length <= dstChainIdToBatchLimit[_dstChainId],
            "batch size exceeds dst batch limit"
        );

        for (uint i = 0; i < _tokenIds.length; i++) {
            _debitFrom(_from, _dstChainId, _toAddress, _tokenIds[i]);
        }

        bytes memory payload = abi.encode(_toAddress, _tokenIds);

        _checkGasLimit(
            _dstChainId,
            FUNCTION_TYPE_SEND,
            _adapterParams,
            dstChainIdToTransferGas[_dstChainId] * _tokenIds.length
        );
        _lzSend(
            _dstChainId,
            payload,
            _refundAddress,
            _zroPaymentAddress,
            _adapterParams,
            _nativeFee
        );
        emit SendToChain(_dstChainId, _from, _toAddress, _tokenIds);
    }

    function claimFeeEarnings() external onlyFeeCollector nonReentrant {
        uint256 _feeEarnedAmount = feeEarnedAmount;
        _validate(_feeEarnedAmount != 0, ERROR_NOTHING_TO_CLAIM);

        uint256 currentEarnings = _feeEarnedAmount;
        feeEarnedAmount = 0;
        feeClaimedAmount += currentEarnings;

        address _feeCollector = feeCollector;
        (bool success, ) = payable(_feeCollector).call{value: currentEarnings}("");
        require(success, "Failed to send Ether");
        emit FeeEarningsClaimed(_feeCollector, currentEarnings);
    }

    function claimReferrerEarnings() external {
        uint256 earnings = referrersEarnedAmount[_msgSender()];
        _validate(earnings != 0, ERROR_NOTHING_TO_CLAIM);

        referrersEarnedAmount[_msgSender()] = 0;
        referrersClaimedAmount[_msgSender()] += earnings;

        (bool sent, ) = payable(_msgSender()).call{value: earnings}("");
        require(sent, "Failed to send Ether");

        emit ReferrerEarningsClaimed(_msgSender(), earnings);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721Enumerable, ONFT721) returns (bool) {
        return interfaceId == type(IONFT721).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _checkFeeCollector() internal view {
        _validate(feeCollector == _msgSender(), ERROR_NOT_FEE_COLLECTOR);
    }

    function _validate(bool _clause, uint8 _errorCode) internal pure {
        if (!_clause) revert ZeriusONFT721_CoreError(_errorCode);
    }

}
