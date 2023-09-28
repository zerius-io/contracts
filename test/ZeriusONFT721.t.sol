// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@layerzerolabs/contracts/mocks/LZEndpointMock.sol";
import "@openzeppelin//contracts/token/ERC721/IERC721Receiver.sol";
import {Test, console2} from "forge-std/Test.sol";

import {ZeriusONFT721} from "../src/ZeriusONFT721.sol";

/**
* @title Test for ZeriusONFT721 contract
* @author polypox
* @notice Use this contract for foundry tests only
*/
contract ZeriusONFT721Test is Test, IERC721Receiver {

    ZeriusONFT721 public zeriusONFT721;
    LZEndpointMock public lzEndpointMock;

    ZeriusONFT721 public dstZeriusONFT721;
    LZEndpointMock public dstLzEndpointMock;

    /********************
    * EVENTS
    */

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

    /********************
    * ERRORS
    */

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

    /********************
   * SETUP
   */
    uint16 public constant OPTIMISM_CHAIN_ID = 1;
    uint16 public constant ARBITRUM_CHAIN_ID = 0;
    uint256 public constant DST_BATCH_LIMIT = 5;
    uint256 public constant END_MINT_ID = 5;
    uint256 public constant START_MINT_ID = 0;
    uint256 public constant MINT_FEE = 0.0001 ether;
    uint256 public constant BRIDGE_FEE = 0.0001 ether;
    uint256 public constant MAX_REFERRAL_EARNING_BIPS = 5000; // 50%
    uint256 public constant MAX_REFERRER_EARNING_BIPS = 10000; // 100%

    address public constant PAYABLE_ADDRESS = 0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B;
    uint256 public constant DENOMINATOR = 10000; // 100%
    uint256 public constant MIN_GAS_TO_TRANSFER = 200_000;
    uint16 public constant LZ_VERSION = 1;
    string public constant IPFS_URI = "https://ipfs.io/ipfs";


    /**
    * @notice Setup testing contract before running tests
    * @dev You can customize settings (eg. CHAIN_ID)
    * by changing setup fields above
    */
    function setUp() public {
        _error = ERC721ReceiveError.None;
        lzEndpointMock = new LZEndpointMock(ARBITRUM_CHAIN_ID);
        zeriusONFT721 = new ZeriusONFT721(
            MIN_GAS_TO_TRANSFER,
            address(lzEndpointMock),
            START_MINT_ID,
            END_MINT_ID,
            MINT_FEE,
            BRIDGE_FEE,
            PAYABLE_ADDRESS
        );

        dstLzEndpointMock = new LZEndpointMock(OPTIMISM_CHAIN_ID);
        dstZeriusONFT721 = new ZeriusONFT721(
            MIN_GAS_TO_TRANSFER,
            address(dstLzEndpointMock),
            START_MINT_ID,
            END_MINT_ID,
            MINT_FEE,
            BRIDGE_FEE,
            PAYABLE_ADDRESS
        );
        lzEndpointMock.setDestLzEndpoint(address(dstZeriusONFT721), address(dstLzEndpointMock));
        dstLzEndpointMock.setDestLzEndpoint(address(zeriusONFT721), address(lzEndpointMock));
        zeriusONFT721.setTrustedRemoteAddress(OPTIMISM_CHAIN_ID, abi.encodePacked(address(dstZeriusONFT721)));
        dstZeriusONFT721.setTrustedRemoteAddress(ARBITRUM_CHAIN_ID, abi.encodePacked(address(zeriusONFT721)));

        zeriusONFT721.setMinDstGas(OPTIMISM_CHAIN_ID, zeriusONFT721.FUNCTION_TYPE_SEND(), MIN_GAS_TO_TRANSFER);
//        zeriusONFT721.setDstChainIdToTransferGas(OPTIMISM_CHAIN_ID, MIN_GAS_TO_TRANSFER);
        zeriusONFT721.setDstChainIdToBatchLimit(OPTIMISM_CHAIN_ID, DST_BATCH_LIMIT);
    }

    /********************
    * TESTS
    */

    //////////////////
    ////// MINT //////
    //////////////////

    /// @custom:test Successfully mint ONFT
    /// @dev See {ZeriusONFT721-mint}
    function test_mint_success() public {
        _error = ERC721ReceiveError.None;
        address minter = address(this);

        uint256 before_tokenCounter = zeriusONFT721.tokenCounter();
        uint256 before_ownerBalance = zeriusONFT721.balanceOf(minter);
        uint256 before_earnings = zeriusONFT721.feeEarnedAmount();

        uint256 nextTokenId = before_tokenCounter;

        vm.expectEmit();
        emit ONFTMinted(
            minter,
            nextTokenId,
            MINT_FEE,
            address(0),
            0
        );
        zeriusONFT721.mint{value: MINT_FEE}();

        uint256 after_tokenCounter = zeriusONFT721.tokenCounter();
        uint256 after_ownerBalance = zeriusONFT721.balanceOf(minter);
        uint256 after_earnings = zeriusONFT721.feeEarnedAmount();
        uint256 earned = after_earnings - before_earnings;

        assertEq(zeriusONFT721.ownerOf(nextTokenId), minter, "Incorrect token owner");
        assertEq(before_tokenCounter + 1, after_tokenCounter, "Token counter is not updated");
        assertEq(before_ownerBalance + 1, after_ownerBalance, "Owner balance is not updated");
        assertEq(earned, MINT_FEE, "Mint fee is not collected");
    }

    /// @custom:test Fail mint because of a recipient error
    /// @dev See {ZeriusONFT721-mint}
    function test_mint_fail_receiveFailedWithoutMessage() public {
        _error = ERC721ReceiveError.RevertWithoutMessage;
        vm.expectRevert();
        zeriusONFT721.mint{value: MINT_FEE}();
    }

    /// @custom:test Fail mint because of insufficient fee
    /// @dev See {ZeriusONFT721-mint}
    function test_mint_fail_invalidMintFee() public {
        _error = ERC721ReceiveError.None;
        vm.expectRevert(abi.encodeWithSelector(ZeriusONFT721_CoreError.selector, ERROR_MINT_INVALID_FEE));
        zeriusONFT721.mint{value: 0}();
    }

    /// @custom:test Fail mint because of reaching minting limit
    /// @dev See {ZeriusONFT721-mint}
    function test_mint_fail_exceedsMintLimit() public mintAmountBeforeTest(END_MINT_ID - START_MINT_ID) {
        _error = ERC721ReceiveError.None;
        vm.expectRevert(abi.encodeWithSelector(ZeriusONFT721_CoreError.selector, ERROR_MINT_EXCEEDS_LIMIT));
        zeriusONFT721.mint{value: MINT_FEE}();
    }

    /// @custom:test Successfully mint ONFT with referrer address and referral earning bips
    /// @dev See {ZeriusONFT721-mint}
    function test_mint_withReferral_success() public {
        _error = ERC721ReceiveError.None;
        address minter = address(this);
        address referrer = PAYABLE_ADDRESS;

        zeriusONFT721.setReferralEarningBips(MAX_REFERRAL_EARNING_BIPS);
        uint256 referrerEarnings = MINT_FEE * MAX_REFERRAL_EARNING_BIPS / DENOMINATOR;

        uint256 before_tokenCounter = zeriusONFT721.tokenCounter();
        uint256 before_ownerBalance = zeriusONFT721.balanceOf(minter);
        uint256 before_earnings = zeriusONFT721.feeEarnedAmount();
        uint256 before_referrerTransactionsCount = zeriusONFT721.referredTransactionsCount(referrer);
        uint256 before_referrerEarnings = zeriusONFT721.referrersEarnedAmount(referrer);

        uint256 nextTokenId = before_tokenCounter;

        vm.expectEmit();
        emit ONFTMinted(
            minter,
            nextTokenId,
            MINT_FEE - referrerEarnings,
            referrer,
            referrerEarnings
        );
        zeriusONFT721.mint{value: MINT_FEE}(referrer);

        uint256 after_tokenCounter = zeriusONFT721.tokenCounter();
        uint256 after_ownerBalance = zeriusONFT721.balanceOf(minter);
        uint256 after_earnings = zeriusONFT721.feeEarnedAmount();
        uint256 earned = after_earnings - before_earnings;
        uint256 after_referrerTransactionsCount = zeriusONFT721.referredTransactionsCount(referrer);
        uint256 after_referrerEarnings = zeriusONFT721.referrersEarnedAmount(referrer);

        assertEq(zeriusONFT721.ownerOf(nextTokenId), minter, "Incorrect token owner");
        assertEq(before_tokenCounter + 1, after_tokenCounter, "Token counter is not updated");
        assertEq(before_ownerBalance + 1, after_ownerBalance, "Owner balance is not updated");
        assertEq(earned, MINT_FEE - referrerEarnings, "Mint fee is not collected");
        assertEq(after_referrerTransactionsCount - before_referrerTransactionsCount, 1, "Referrer transactions is not updated");
        assertEq(after_referrerEarnings - before_referrerEarnings, referrerEarnings, "Referrer earnings is not updated");
    }

    /// @custom:test Successfully mint ONFT with referrer address and referrer earning bips
    /// @dev See {ZeriusONFT721-mint}
    function test_mint_withReferrerEarningBips_success() public {
        _error = ERC721ReceiveError.None;
        address minter = address(this);
        address referrer = PAYABLE_ADDRESS;

        zeriusONFT721.setEarningBipsForReferrer(referrer, MAX_REFERRAL_EARNING_BIPS);
        uint256 referrerEarnings = MINT_FEE * MAX_REFERRAL_EARNING_BIPS / DENOMINATOR;

        uint256 before_tokenCounter = zeriusONFT721.tokenCounter();
        uint256 before_ownerBalance = zeriusONFT721.balanceOf(minter);
        uint256 before_earnings = zeriusONFT721.feeEarnedAmount();
        uint256 before_referrerTransactionsCount = zeriusONFT721.referredTransactionsCount(referrer);
        uint256 before_referrerEarnings = zeriusONFT721.referrersEarnedAmount(referrer);

        uint256 nextTokenId = before_tokenCounter;

        vm.expectEmit();
        emit ONFTMinted(
            minter,
            nextTokenId,
            MINT_FEE - referrerEarnings,
            referrer,
            referrerEarnings
        );
        zeriusONFT721.mint{value: MINT_FEE}(referrer);

        uint256 after_tokenCounter = zeriusONFT721.tokenCounter();
        uint256 after_ownerBalance = zeriusONFT721.balanceOf(minter);
        uint256 after_earnings = zeriusONFT721.feeEarnedAmount();
        uint256 earned = after_earnings - before_earnings;
        uint256 after_referrerTransactionsCount = zeriusONFT721.referredTransactionsCount(referrer);
        uint256 after_referrerEarnings = zeriusONFT721.referrersEarnedAmount(referrer);

        assertEq(zeriusONFT721.ownerOf(nextTokenId), minter, "Incorrect token owner");
        assertEq(before_tokenCounter + 1, after_tokenCounter, "Token counter is not updated");
        assertEq(before_ownerBalance + 1, after_ownerBalance, "Owner balance is not updated");
        assertEq(earned, MINT_FEE - referrerEarnings, "Mint fee is not collected");
        assertEq(after_referrerTransactionsCount - before_referrerTransactionsCount, 1, "Referrer transactions is not updated");
        assertEq(after_referrerEarnings - before_referrerEarnings, referrerEarnings, "Referrer earnings is not updated");
    }

    /// @custom:test Fail mint ONFT with referrer address because of incorrect referrer
    /// @dev See {ZeriusONFT721-mint}
    function test_mint_withReferrer_fail_senderReferrer() public {
        _error = ERC721ReceiveError.None;
        address referrer = address(this);

        vm.expectRevert(abi.encodeWithSelector(ZeriusONFT721_CoreError.selector, ERROR_INVALID_REFERER));
        zeriusONFT721.mint{value: MINT_FEE}(referrer);
    }

    ////////////////////
    ////// BRIDGE //////
    ////////////////////

    /// @custom:test Bridge ONFT
    /// @dev See {ZeriusONFT721-sendFrom}
    function test_sendFrom_success() public mintBeforeTest {
        address sender = address(this);
        uint256 before_tokenCounter = zeriusONFT721.tokenCounter();
        uint256 before_ownerBalance = zeriusONFT721.balanceOf(sender);
        uint256 before_earnings = zeriusONFT721.feeEarnedAmount();
        uint256 tokenId = before_tokenCounter - 1;

        (uint256 nativeFee, ) = zeriusONFT721.estimateSendFee(
            OPTIMISM_CHAIN_ID,
            abi.encodePacked(PAYABLE_ADDRESS),
            tokenId,
            false,
            abi.encodePacked(LZ_VERSION, MIN_GAS_TO_TRANSFER)
        );

        vm.expectEmit();
        emit BridgeFeeEarned(sender, OPTIMISM_CHAIN_ID, BRIDGE_FEE);
        zeriusONFT721.sendFrom{value: BRIDGE_FEE + nativeFee}(
            address(this),
            OPTIMISM_CHAIN_ID,
            abi.encodePacked(PAYABLE_ADDRESS),
            tokenId,
            payable(address(this)),
            address(0x0),
            abi.encodePacked(LZ_VERSION, MIN_GAS_TO_TRANSFER)
        );

        uint256 after_tokenCounter = zeriusONFT721.tokenCounter();
        uint256 after_ownerBalance = zeriusONFT721.balanceOf(sender);
        uint256 after_earnings = zeriusONFT721.feeEarnedAmount();
        uint256 earned = after_earnings - before_earnings;

        assertEq(zeriusONFT721.ownerOf(tokenId), address(zeriusONFT721), "Token is not transferred");
        assertEq(before_tokenCounter, after_tokenCounter, "Counter updated");
        assertEq(before_ownerBalance - 1, after_ownerBalance, "Balance is not updated");
        assertEq(earned, BRIDGE_FEE, "Earnings are not updated");
    }

    /// @custom:test Bridge batch of ONFTs
    /// @dev See {ZeriusONFT721-sendBatchFrom}
    function test_sendBatchFrom_success() public mintAmountBeforeTest(DST_BATCH_LIMIT) {
        address sender = address(this);
        uint256 before_tokenCounter = zeriusONFT721.tokenCounter();
        uint256 before_ownerBalance = zeriusONFT721.balanceOf(sender);
        uint256 before_earnings = zeriusONFT721.feeEarnedAmount();
        uint256 tokensCount = DST_BATCH_LIMIT;
        uint256[] memory tokenIds = new uint256[](tokensCount);
        for (uint256 i; i < tokensCount; i++) {
            tokenIds[i] = i;
        }

        (uint256 nativeFee, ) = zeriusONFT721.estimateSendBatchFee(
            OPTIMISM_CHAIN_ID,
            abi.encodePacked(PAYABLE_ADDRESS),
            tokenIds,
            false,
            abi.encodePacked(LZ_VERSION, MIN_GAS_TO_TRANSFER)
        );

        vm.expectEmit();
        emit BridgeFeeEarned(sender, OPTIMISM_CHAIN_ID, BRIDGE_FEE);
        zeriusONFT721.sendBatchFrom{value: BRIDGE_FEE + nativeFee}(
            address(this),
            OPTIMISM_CHAIN_ID,
            abi.encodePacked(PAYABLE_ADDRESS),
            tokenIds,
            payable(address(this)),
            address(0x0),
            abi.encodePacked(LZ_VERSION, MIN_GAS_TO_TRANSFER)
        );

        uint256 after_tokenCounter = zeriusONFT721.tokenCounter();
        uint256 after_ownerBalance = zeriusONFT721.balanceOf(sender);
        uint256 after_earnings = zeriusONFT721.feeEarnedAmount();
        uint256 earned = after_earnings - before_earnings;

        for (uint256 i; i < tokensCount; i++) {
            assertEq(zeriusONFT721.ownerOf(tokenIds[i]), address(zeriusONFT721), "Token is not transferred");
        }
        assertEq(before_tokenCounter, after_tokenCounter, "Counter updated");
        assertEq(before_ownerBalance - tokensCount, after_ownerBalance, "Balance is not updated");
        assertEq(earned, BRIDGE_FEE, "Earnings are not updated");
    }

    /// @custom:test Fail bridge batch of ONFTs because of empty list of sent tokens
    /// @dev See {ZeriusONFT721-sendBatchFrom}
    function test_sendBatchFrom_fail_emptyTokenIds() public {
        uint256[] memory tokenIds;

        vm.expectRevert("tokenIds[] is empty");
        zeriusONFT721.sendBatchFrom{value: BRIDGE_FEE + 0.1 ether}(
            address(this),
            OPTIMISM_CHAIN_ID,
            abi.encodePacked(PAYABLE_ADDRESS),
            tokenIds,
            payable(address(this)),
            address(0x0),
            abi.encodePacked(LZ_VERSION, MIN_GAS_TO_TRANSFER * 4)
        );
    }

    /// @custom:test Fail bridge batch of ONFTs because of exceeding batch limit
    /// @dev See {ZeriusONFT721-sendBatchFrom}
    function test_sendBatchFrom_fail_exceedsBatchLimit() public {
        uint256[] memory tokenIds = new uint256[](DST_BATCH_LIMIT + 1);

        vm.expectRevert("batch size exceeds dst batch limit");
        zeriusONFT721.sendBatchFrom{value: BRIDGE_FEE + 0.1 ether}(
            address(this),
            OPTIMISM_CHAIN_ID,
            abi.encodePacked(PAYABLE_ADDRESS),
            tokenIds,
            payable(address(this)),
            address(0x0),
            abi.encodePacked(LZ_VERSION, MIN_GAS_TO_TRANSFER * 4)
        );
    }

    ///////////////////
    ////// CLAIM //////
    ///////////////////

    /// @custom:test Claim fee earnings
    /// @dev See {ZeriusONFT721-claimFeeEarnings}
    function test_claimFeeEarnings_success() public mintBeforeTest {
        uint256 before_feeCollectorBalance = PAYABLE_ADDRESS.balance;
        uint256 before_feeEarnedAmount = zeriusONFT721.feeEarnedAmount();
        uint256 before_feeClaimedAmount = zeriusONFT721.feeClaimedAmount();

        vm.startPrank(PAYABLE_ADDRESS);
        vm.expectEmit();
        emit FeeEarningsClaimed(PAYABLE_ADDRESS, before_feeEarnedAmount);
        zeriusONFT721.claimFeeEarnings();
        vm.stopPrank();

        uint256 after_feeCollectorBalance = PAYABLE_ADDRESS.balance;
        uint256 after_feeEarnedAmount = zeriusONFT721.feeEarnedAmount();
        uint256 after_feeClaimedAmount = zeriusONFT721.feeClaimedAmount();

        assertEq(after_feeCollectorBalance - before_feeCollectorBalance, MINT_FEE, "Fee collector balace is incorrect");
        assertEq(after_feeEarnedAmount, 0, "Fee earned amount is not 0 after claim");
        assertEq(after_feeClaimedAmount - before_feeClaimedAmount, MINT_FEE, "Fee claimed amount is incorrect");
    }

    /// @custom:test Fail claiming fee earnings because of calling claim from incorrect address
    /// @dev See {ZeriusONFT721-claimFeeEarnings}
    function test_claimFeeEarnings_fail_calledByIncorrectAddress() public mintBeforeTest {
        vm.expectRevert(abi.encodeWithSelector(ZeriusONFT721_CoreError.selector, ERROR_NOT_FEE_COLLECTOR));
        zeriusONFT721.claimFeeEarnings();
    }

    /// @custom:test Fail claiming fee earnings because of incorrect earned amount
    /// @dev See {ZeriusONFT721-claimFeeEarnings}
    function test_claimFeeEarnings_fail_nothingToClaim() public {
        vm.startPrank(PAYABLE_ADDRESS);
        vm.expectRevert(abi.encodeWithSelector(ZeriusONFT721_CoreError.selector, ERROR_NOTHING_TO_CLAIM));
        zeriusONFT721.claimFeeEarnings();
        vm.stopPrank();
    }

    /// @custom:test Fail claiming fee earnings because of failing funds transfer
    /// @dev See {ZeriusONFT721-claimFeeEarnings}
    function test_claimFeeEarnings_fail_failedSendEth() public mintBeforeTest {
        zeriusONFT721.setFeeCollector(address(lzEndpointMock));

        vm.startPrank(address(lzEndpointMock));
        vm.expectRevert("Failed to send Ether");
        zeriusONFT721.claimFeeEarnings();
        vm.stopPrank();
    }

    /// @custom:test Claiming referral earnings
    /// @dev See {ZeriusONFT721-claimReferrerEarnings}
    function test_claimReferralEarnings_success() public
        mintRefBeforeTest(PAYABLE_ADDRESS, 0, MAX_REFERRAL_EARNING_BIPS)
    {
        address referrer = PAYABLE_ADDRESS;
        uint256 referrerEarnings = zeriusONFT721.referrersEarnedAmount(referrer);

        vm.startPrank(referrer);
        vm.expectEmit();
        emit ReferrerEarningsClaimed(referrer, referrerEarnings);
        zeriusONFT721.claimReferrerEarnings();
        vm.stopPrank();

        uint256 after_referrerEarnings = zeriusONFT721.referrersEarnedAmount(referrer);
        uint256 after_referrerClaimed = zeriusONFT721.referrersClaimedAmount(referrer);

        assertEq(after_referrerEarnings, 0, "Referrer earnings is not 0 after claim");
        assertEq(after_referrerClaimed, referrerEarnings, "Referrer claimed amount is not updated");
    }

    /// @custom:test Fail claiming referral earnings because of failed send funds
    /// @dev See {ZeriusONFT721-claimReferrerEarnings}
    function test_claimReferralEarnings_fail_failedSendEth() public
    mintRefBeforeTest(address(lzEndpointMock), 0, MAX_REFERRAL_EARNING_BIPS)
    {
        address referrer = address(lzEndpointMock);

        vm.startPrank(referrer);
        vm.expectRevert("Failed to send Ether");
        zeriusONFT721.claimReferrerEarnings();
        vm.stopPrank();
    }

    /// @custom:test Fail claiming referral earnings because of insufficient earnings
    /// @dev See {ZeriusONFT721-claimReferrerEarnings}
    function test_claimReferralEarnings_fail_nothingToClaim() public {
        address referrer = PAYABLE_ADDRESS;

        vm.startPrank(referrer);
        vm.expectRevert(abi.encodeWithSelector(ZeriusONFT721_CoreError.selector, ERROR_NOTHING_TO_CLAIM));
        zeriusONFT721.claimReferrerEarnings();
        vm.stopPrank();
    }

    ///////////////////////////////
    ////// SETTERS / GETTERS //////
    ///////////////////////////////

    /// @custom:test Setting new mint fee
    /// @dev See {ZeriusONFT721-setMintFee}
    function test_setMintFee() public {
        uint256 before_mintFee = zeriusONFT721.mintFee();
        uint256 newMintFee = MINT_FEE * 2;

        vm.expectEmit();
        emit MintFeeChanged(before_mintFee, newMintFee);
        zeriusONFT721.setMintFee(newMintFee);

        uint256 after_mintFee = zeriusONFT721.mintFee();

        assertEq(after_mintFee, newMintFee, "Mint fee is not changed");
    }

    /// @custom:test Setting new bridge fee
    /// @dev See {ZeriusONFT721-setBridgeFee}
    function test_setBridgeFee() public {
        uint256 before_bridgeFee = zeriusONFT721.bridgeFee();
        uint256 newBridgeFee = BRIDGE_FEE * 2;

        vm.expectEmit();
        emit BridgeFeeChanged(before_bridgeFee, newBridgeFee);
        zeriusONFT721.setBridgeFee(newBridgeFee);

        uint256 after_bridgeFee = zeriusONFT721.bridgeFee();

        assertEq(after_bridgeFee, newBridgeFee, "Bridge fee is not changed");
    }

    /// @custom:test Setting new referral earning bips
    /// @dev See {ZeriusONFT721-setReferralEarningBips}
    function test_setReferralEarningBips_success() public {
        uint256 before_referralEarningBips = zeriusONFT721.referralEarningBips();
        uint256 newReferralEarningBips = MAX_REFERRAL_EARNING_BIPS;

        vm.expectEmit();
        emit ReferralEarningBipsChanged(before_referralEarningBips, newReferralEarningBips);
        zeriusONFT721.setReferralEarningBips(newReferralEarningBips);

        uint256 after_referralEarningBips = zeriusONFT721.referralEarningBips();

        assertEq(after_referralEarningBips, newReferralEarningBips);
    }

    /// @custom:test Fail to set new referral earning bips because of high bips value
    /// @dev See {ZeriusONFT721-setReferralEarningBips}
    function test_setReferralEarningBips_fail_bipsTooHigh() public {
        uint256 newReferralEarningBips = MAX_REFERRAL_EARNING_BIPS * 2;

        vm.expectRevert(abi.encodeWithSelector(ZeriusONFT721_CoreError.selector, ERROR_REFERRAL_BIPS_TOO_HIGH));
        zeriusONFT721.setReferralEarningBips(newReferralEarningBips);
    }

    /// @custom:test Setting new earning bips for referrer
    /// @dev See {ZeriusONFT721-setEarningBipsForReferrer}
    function test_setEarningBipsForReferrer_success() public {
        address referrer = PAYABLE_ADDRESS;
        uint256 newReferrerEarningBips = MAX_REFERRER_EARNING_BIPS;

        vm.expectEmit();
        emit EarningBipsForReferrerChanged(referrer, newReferrerEarningBips);
        zeriusONFT721.setEarningBipsForReferrer(referrer, newReferrerEarningBips);

        uint256 after_earningBipsForReferrer = zeriusONFT721.referrersEarningBips(PAYABLE_ADDRESS);

        assertEq(after_earningBipsForReferrer, newReferrerEarningBips, "Referrer earning bips is not updated");
    }

    /// @custom:test Fail to set new earning bips for referrer because of high bips value
    /// @dev See {ZeriusONFT721-setEarningBipsForReferrer}
    function test_setEarningBipsForReferrer_fail_bipsTooHigh() public {
        address referrer = PAYABLE_ADDRESS;
        uint256 newReferrerEarningBips = MAX_REFERRER_EARNING_BIPS * 2;

        vm.expectRevert(abi.encodeWithSelector(ZeriusONFT721_CoreError.selector, ERROR_REFERRAL_BIPS_TOO_HIGH));
        zeriusONFT721.setEarningBipsForReferrer(referrer, newReferrerEarningBips);
    }

    /// @custom:test Setting new fee collector
    /// @dev See {ZeriusONFT721-setFeeCollector}
    function test_setFeeCollector_success() public {
        address before_feeCollector = zeriusONFT721.feeCollector();
        address newFeeCollector = PAYABLE_ADDRESS;

        vm.expectEmit();
        emit FeeCollectorChanged(before_feeCollector, newFeeCollector);
        zeriusONFT721.setFeeCollector(newFeeCollector);

        address after_feeCollector = zeriusONFT721.feeCollector();

        assertEq(after_feeCollector, newFeeCollector, "Fee collector is not changed");
    }

    /// @custom:test Fail to set new fee collector because of invalid address
    /// @dev See {ZeriusONFT721-setFeeCollector}
    function test_setFeeCollector_fail_invalidCollectorAddress() public {
        address newFeeCollector = address(0x0);

        vm.expectRevert(abi.encodeWithSelector(ZeriusONFT721_CoreError.selector, ERROR_INVALID_COLLECTOR_ADDRESS));
        zeriusONFT721.setFeeCollector(newFeeCollector);
    }

    /// @custom:test Locking base URI
    /// @dev See {ZeriusONFT721-lockTokenBaseURI}
    function test_lockTokenBaseURI_success() public {
        bool before_tokenURILocked = zeriusONFT721.tokenBaseURILocked();
        assertFalse(before_tokenURILocked);

        vm.expectEmit();
        emit TokenURILocked();
        zeriusONFT721.lockTokenBaseURI();

        bool after_tokenURILocked = zeriusONFT721.tokenBaseURILocked();

        assertTrue(after_tokenURILocked);
    }

    /// @custom:test Fail locking base URI because of URI is already locked
    /// @dev See {ZeriusONFT721-lockTokenBaseURI}
    function test_lockTokenBaseURI_fail_tokenURILocked() public {
        zeriusONFT721.lockTokenBaseURI();

        vm.expectRevert(abi.encodeWithSelector(ZeriusONFT721_CoreError.selector, ERROR_TOKEN_URI_LOCKED));
        zeriusONFT721.lockTokenBaseURI();
    }

    /// @custom:test Set new base URI
    /// @dev See {ZeriusONFT721-setTokenBaseURI}
    function test_setTokenBaseURI_success() public {
        string memory before_baseTokenURI = "";
        string memory newBaseTokenURI = IPFS_URI;

        vm.expectEmit();
        emit TokenURIChanged(before_baseTokenURI, newBaseTokenURI);
        zeriusONFT721.setTokenBaseURI(newBaseTokenURI);
    }

    /// @custom:test Fail set new base URI because of token URI is locked
    /// @dev See {ZeriusONFT721-setTokenBaseURI}
    function test_setTokenBaseURI_fail_tokenURILocked() public {
        zeriusONFT721.lockTokenBaseURI();

        string memory newBaseTokenURI = IPFS_URI;

        vm.expectRevert(abi.encodeWithSelector(ZeriusONFT721_CoreError.selector, ERROR_TOKEN_URI_LOCKED));
        zeriusONFT721.setTokenBaseURI(newBaseTokenURI);
    }

    /// @custom:test Get token URI
    /// @dev See {ZeriusONFT721-tokenURI}
    function test_tokenURI_success() public mintBeforeTest {
        zeriusONFT721.setTokenBaseURI(IPFS_URI);
        uint256 tokenId = zeriusONFT721.tokenCounter() - 1;

        string memory tokenURI = zeriusONFT721.tokenURI(tokenId);

        assertEq(tokenURI, "https://ipfs.io/ipfs?id=0", "Invalid token URI");
    }

    /// @custom:test Fail get token URI because of token id is not exist
    /// @dev See {ZeriusONFT721-tokenURI}
    function test_tokenURI_fail_invalidTokenId() public {
        uint256 tokenId = 10;

        vm.expectRevert(abi.encodeWithSelector(ZeriusONFT721_CoreError.selector, ERROR_INVALID_TOKEN_ID));
        zeriusONFT721.tokenURI(tokenId);
    }

    /********************
    * TEST HELPERS
    */

    /**
    * @notice Shortcut for minting 1 token before running test
    * @dev Set _error to ERC721ReceiveError.None to make sure tokens will be minted successfully
    */
    modifier mintBeforeTest {
        _error = ERC721ReceiveError.None;
        zeriusONFT721.mint{value: MINT_FEE}();
        _;
    }

    /**
    * @notice Shortcut for minting `amount` tokens before running test
    * @dev Set _error to ERC721ReceiveError.None to make sure tokens will be minted successfully
    *
    * @param amount   The amount of tokens that should has been minted
    */
    modifier mintAmountBeforeTest(uint256 amount) {
        _error = ERC721ReceiveError.None;
        for (uint256 i; i < amount; i++) {
            zeriusONFT721.mint{value: MINT_FEE}();
        }
        _;
    }

    /**
    * @notice Shortcut for minting `amount` tokens with referrer `referrer` before running test
    * @dev Set _error to ERC721ReceiveError.None to make sure tokens will be minted successfully
    *
    * @param referrer      The referrer address
    * @param referralBips  Refferal shares from mint
    * @param referrerBips  Refferer shares from mint
    */
    modifier mintRefBeforeTest(
        address referrer,
        uint256 referralBips,
        uint256 referrerBips
    ) {
        _error = ERC721ReceiveError.None;
        zeriusONFT721.setReferralEarningBips(referralBips);
        zeriusONFT721.setEarningBipsForReferrer(referrer, referrerBips);
        zeriusONFT721.mint{value: MINT_FEE}(referrer);
        _;
    }

    /********************
    * IERC721Receiver Mock implementation
    */

    /**
    * @dev Mocks for onERC721Received behaviour
    * @dev None                     Successful receive
    * @dev RevertWithMessage        Revert receive with error message
    * @dev RevertWithoutMessage     Revert receive
    * @dev Panic                    Cause panic error (eg. division by zero)
    */
    enum ERC721ReceiveError {
        None,
        RevertWithMessage,
        RevertWithoutMessage,
        Panic
    }

    ERC721ReceiveError private _error;

    bytes4 public constant ERC721_RECEIVE_RETVAL = IERC721Receiver.onERC721Received.selector;

    /**
    * @dev See {IERC721Receiver-onERC721Received}
    *
    * @notice Mock IERC721Receiver logic
    * @dev Customize _error to imitate different behaviour
    */
    function onERC721Received(
        address, // operator
        address, // from
        uint256, // tokenId
        bytes memory // data
    ) public view override returns (bytes4) {
        if (_error == ERC721ReceiveError.RevertWithMessage) {
            revert("ERC721ReceiverMock: reverting");
        } else if (_error == ERC721ReceiveError.RevertWithoutMessage) {
            revert();
        } else if (_error == ERC721ReceiveError.Panic) {
            uint256 a = uint256(0) / uint256(0);
            a;
        }
        return ERC721_RECEIVE_RETVAL;
    }

    /// Impl for receiving funds

    fallback() external {}

    receive() external payable {}
}
