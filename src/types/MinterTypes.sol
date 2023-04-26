// SPDX-License-Identifier: MIT
pragma solidity >=0.8.14;

import {AggregatorV2V3Interface} from "../vendor/flux/IFlux.sol";
import {FixedPoint} from "../libs/FixedPoint.sol";
import {IKreskoAssetAnchor} from "../interfaces/IKreskoAssetAnchor.sol";

/* solhint-disable state-visibility */

/* -------------------------------------------------------------------------- */
/*                                  CONSTANTS                                 */
/* -------------------------------------------------------------------------- */

library Constants {
    uint256 constant ONE_HUNDRED_PERCENT = 1e18;

    /// @dev The maximum configurable close fee.
    uint256 constant MAX_CLOSE_FEE = 10e16; // 10%

    /// @dev The maximum configurable open fee.
    uint256 constant MAX_OPEN_FEE = 10e16; // 10%

    /// @dev The minimum configurable minimum collateralization ratio.
    uint256 constant MIN_COLLATERALIZATION_RATIO = ONE_HUNDRED_PERCENT;

    /// @dev The minimum configurable liquidation incentive multiplier.
    /// This means liquidator only receives equal amount of collateral to debt repaid.
    uint256 constant MIN_LIQUIDATION_INCENTIVE_MULTIPLIER = ONE_HUNDRED_PERCENT;

    /// @dev The maximum configurable liquidation incentive multiplier.
    /// This means liquidator receives 25% bonus collateral compared to the debt repaid.
    uint256 constant MAX_LIQUIDATION_INCENTIVE_MULTIPLIER = 1.25e18; // 125%

    /// @dev The maximum configurable minimum debt USD value.
    uint256 constant MAX_DEBT_VALUE = 1000e18; // $1,000
}

/* -------------------------------------------------------------------------- */
/*                                    ENUM                                    */
/* -------------------------------------------------------------------------- */

/**
 * @dev Protocol user facing actions
 *
 * Deposit = 0
 * Withdraw = 1,
 * Repay = 2,
 * Borrow = 3,
 * Liquidate = 4
 */
enum Action {
    Deposit,
    Withdraw,
    Repay,
    Borrow,
    Liquidation
}
/**
 * @dev Fee types
 *
 * Open = 0
 * Close = 1
 */
enum Fee {
    Open,
    Close
}

/* ========================================================================== */
/*                                   STRUCTS                                  */
/* ========================================================================== */

/**
 * @notice Initialization arguments for the protocol
 */
struct MinterInitArgs {
    address admin;
    address council;
    address treasury;
    uint8 extOracleDecimals;
    uint256 liquidationIncentiveMultiplier;
    uint256 minimumCollateralizationRatio;
    uint256 minimumDebtValue;
    uint256 liquidationThreshold;
}

/**
 * @notice Configurable parameters within the protocol
 */

struct MinterParams {
    FixedPoint.Unsigned minimumCollateralizationRatio;
    FixedPoint.Unsigned liquidationIncentiveMultiplier;
    FixedPoint.Unsigned minimumDebtValue;
    FixedPoint.Unsigned liquidationThreshold;
    address feeRecipient;
    uint8 extOracleDecimals;
}

/**
 * @notice Information on a token that is a KreskoAsset.
 * @dev Each KreskoAsset has 18 decimals.
 * @param kFactor The k-factor used for calculating the required collateral value for KreskoAsset debt.
 * @param oracle The oracle that provides the USD price of one KreskoAsset.
 * @param supplyLimit The total supply limit of the KreskoAsset.
 * @param anchor The anchor address
 * @param closeFee The percentage paid in fees when closing a debt position of this type.
 * @param openFee The percentage paid in fees when opening a debt position of this type.
 * @param exists Whether the KreskoAsset exists within the protocol.
 */
struct KrAsset {
    FixedPoint.Unsigned kFactor;
    AggregatorV2V3Interface oracle;
    AggregatorV2V3Interface marketStatusOracle;
    uint256 supplyLimit;
    address anchor;
    FixedPoint.Unsigned closeFee;
    FixedPoint.Unsigned openFee;
    bool exists;
}

/**
 * @notice Information on a token that can be used as collateral.
 * @dev Setting the factor to zero effectively makes the asset useless as collateral while still allowing
 * it to be deposited and withdrawn.
 * @param factor The collateral factor used for calculating the value of the collateral.
 * @param oracle The oracle that provides the USD price of one collateral asset.
 * @param anchor If the collateral is a KreskoAsset, the anchor address
 * @param decimals The decimals for the token, stored here to avoid repetitive external calls.
 * @param exists Whether the collateral asset exists within the protocol.
 */
struct CollateralAsset {
    FixedPoint.Unsigned factor;
    AggregatorV2V3Interface oracle;
    AggregatorV2V3Interface marketStatusOracle;
    address anchor;
    uint8 decimals;
    bool exists;
}

/// @notice Configuration for pausing `Action`
struct Pause {
    bool enabled;
    uint256 timestamp0;
    uint256 timestamp1;
}

/// @notice Safety configuration for assets
struct SafetyState {
    Pause pause;
}

/**
 * @title Storage layout for the minter state
 * @author Kresko
 */
struct MinterState {
    /* -------------------------------------------------------------------------- */
    /*                               Initialization                               */
    /* -------------------------------------------------------------------------- */

    /// @notice Initialization version
    uint256 initializations;
    bytes32 domainSeparator;
    /* -------------------------------------------------------------------------- */
    /*                           Configurable Parameters                          */
    /* -------------------------------------------------------------------------- */

    /// @notice The recipient of protocol fees.
    address feeRecipient;
    /// @notice The factor used to calculate the incentive a liquidator receives in the form of seized collateral.
    FixedPoint.Unsigned liquidationIncentiveMultiplier;
    /// @notice The absolute minimum ratio of collateral value to debt value used to calculate collateral requirements.
    FixedPoint.Unsigned minimumCollateralizationRatio;
    /// @notice The minimum USD value of an individual synthetic asset debt position.
    FixedPoint.Unsigned minimumDebtValue;
    /// @notice The collateralization ratio at which positions may be liquidated.
    FixedPoint.Unsigned liquidationThreshold;
    /// @notice Flag tells if there is a need to perform safety checks on user actions
    bool safetyStateSet;
    /// @notice asset -> action -> state
    mapping(address => mapping(Action => SafetyState)) safetyState;
    /* -------------------------------------------------------------------------- */
    /*                              Collateral Assets                             */
    /* -------------------------------------------------------------------------- */

    /// @notice Mapping of collateral asset token address to information on the collateral asset.
    mapping(address => CollateralAsset) collateralAssets;
    /**
     * @notice Mapping of account -> asset -> deposit amount
     */
    mapping(address => mapping(address => uint256)) collateralDeposits;
    /// @notice Mapping of account -> collateral asset addresses deposited
    mapping(address => address[]) depositedCollateralAssets;
    /* -------------------------------------------------------------------------- */
    /*                                Kresko Assets                               */
    /* -------------------------------------------------------------------------- */

    /// @notice Mapping of kresko asset token address to information on the Kresko asset.
    mapping(address => KrAsset) kreskoAssets;
    /// @notice Mapping of account -> krAsset -> debt amount owed to the protocol
    mapping(address => mapping(address => uint256)) kreskoAssetDebt;
    /// @notice Mapping of account -> addresses of borrowed krAssets
    mapping(address => address[]) mintedKreskoAssets;
    /// @notice The AMM oracle address.
    address ammOracle;
    /// @notice Offchain oracle decimals
    uint8 extOracleDecimals;
}

// Storage position
bytes32 constant MINTER_STORAGE_POSITION = keccak256("kresko.minter.storage");

function ms() pure returns (MinterState storage state) {
    bytes32 position = MINTER_STORAGE_POSITION;
    assembly {
        state.slot := position
    }
}
