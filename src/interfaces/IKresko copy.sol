// SPDX-License-Identifier: MIT
pragma solidity >=0.8.14;

import {MinterInitArgs, KrAsset, CollateralAsset, MinterParams, Action, SafetyState} from "../types/MinterTypes.sol";
import {FixedPoint} from "../libs/FixedPoint.sol";
import {StabilityRateParams, StabilityRateConfig} from "../types/StabilityRateTypes.sol";

interface IKresko {
    function initialize(MinterInitArgs calldata args) external;

    function toggleAssetsPaused(
        address[] memory _assets,
        Action _action,
        bool _withDuration,
        uint256 _duration
    ) external;

    function safetyStateSet() external view returns (bool);

    function safetyStateFor(
        address _asset,
        Action _action
    ) external view returns (SafetyState memory);

    function burnKreskoAsset(
        address _account,
        address _kreskoAsset,
        uint256 _amount,
        uint256 _mintedKreskoAssetIndex
    ) external;

    function batchCloseKrAssetDebtPositions(address _account) external;

    function closeKrAssetDebtPosition(
        address _account,
        address _kreskoAsset
    ) external;

    function domainSeparator() external view returns (bytes32);

    function minterInitializations() external view returns (uint256);

    function feeRecipient() external view returns (address);

    function ammOracle() external view returns (address);

    function extOracleDecimals() external view returns (uint8);

    function liquidationThreshold()
        external
        view
        returns (FixedPoint.Unsigned memory);

    function liquidationIncentiveMultiplier()
        external
        view
        returns (FixedPoint.Unsigned memory);

    function minimumCollateralizationRatio()
        external
        view
        returns (FixedPoint.Unsigned memory);

    function minimumDebtValue()
        external
        view
        returns (FixedPoint.Unsigned memory);

    function krAssetExists(address _krAsset) external view returns (bool);

    function kreskoAsset(address _asset) external view returns (KrAsset memory);

    function collateralAsset(
        address _asset
    ) external view returns (CollateralAsset memory);

    function collateralExists(
        address _collateralAsset
    ) external view returns (bool);

    function getAllParams() external view returns (MinterParams memory);

    function getCollateralValueAndOraclePrice(
        address _collateralAsset,
        uint256 _amount,
        bool _ignoreCollateralFactor
    )
        external
        view
        returns (FixedPoint.Unsigned memory, FixedPoint.Unsigned memory);

    function getKrAssetValue(
        address _kreskoAsset,
        uint256 _amount,
        bool _ignoreKFactor
    ) external view returns (FixedPoint.Unsigned memory);

    function addCollateralAsset(
        address _collateralAsset,
        address _anchor,
        uint256 _factor,
        address _oracle,
        address _marketStatusOracle
    ) external;

    function addKreskoAsset(
        address _krAsset,
        address _anchor,
        uint256 _kFactor,
        address _oracle,
        address _marketStatusOracle,
        uint256 _supplyLimit,
        uint256 _closeFee,
        uint256 _openFee
    ) external;

    function updateCollateralAsset(
        address _collateralAsset,
        address _anchor,
        uint256 _factor,
        address _oracle,
        address _marketStatusOracle
    ) external;

    function updateFeeRecipient(address _feeRecipient) external;

    function updateKreskoAsset(
        address _krAsset,
        address _anchor,
        uint256 _kFactor,
        address _oracle,
        address _marketStatusOracle,
        uint256 _supplyLimit,
        uint256 _closeFee,
        uint256 _openFee
    ) external;

    function updateLiquidationIncentiveMultiplier(
        uint256 _liquidationIncentiveMultiplier
    ) external;

    function updateMinimumCollateralizationRatio(
        uint256 _minimumCollateralizationRatio
    ) external;

    function updateMinimumDebtValue(uint256 _minimumDebtValue) external;

    function updateLiquidationThreshold(uint256 _minimumDebtValue) external;

    function updateAMMOracle(address _ammOracle) external;

    function updateExtOracleDecimals(uint8 _decimals) external;

    function depositCollateral(
        address _account,
        address _collateralAsset,
        uint256 _amount
    ) external;

    function withdrawCollateral(
        address _account,
        address _collateralAsset,
        uint256 _amount,
        uint256 _depositedCollateralAssetIndex
    ) external;

    function batchLiquidateInterest(
        address _account,
        address _collateralAssetToSeize
    ) external;

    function liquidateInterest(
        address _account,
        address _repayKreskoAsset,
        address _collateralAssetToSeize
    ) external;

    function calculateMaxLiquidatableValueForAssets(
        address _account,
        address _repayKreskoAsset,
        address _collateralAssetToSeize
    ) external view returns (FixedPoint.Unsigned memory maxLiquidatableUSD);

    function isAccountLiquidatable(
        address _account
    ) external view returns (bool);

    function liquidate(
        address _account,
        address _repayKreskoAsset,
        uint256 _repayAmount,
        address _collateralAssetToSeize,
        uint256 _mintedKreskoAssetIndex,
        uint256 _depositedCollateralAssetIndex
    ) external;

    function setupStabilityRateParams(
        address _asset,
        StabilityRateParams memory _setup
    ) external;

    function updateStabilityRateParams(
        address _asset,
        StabilityRateParams memory _setup
    ) external;

    function updateStabilityRateAndIndexForAsset(address _asset) external;

    function updateKiss(address _kiss) external;

    function repayStabilityRateInterestPartial(
        address _account,
        address _kreskoAsset,
        uint256 _kissRepayAmount
    ) external;

    function repayFullStabilityRateInterest(
        address _account,
        address _kreskoAsset
    ) external returns (uint256 kissRepayAmount);

    function batchRepayFullStabilityRateInterest(
        address _account
    ) external returns (uint256 kissRepayAmount);

    function getStabilityRateForAsset(
        address _asset
    ) external view returns (uint256 stabilityRate);

    function getPriceRateForAsset(
        address _asset
    ) external view returns (uint256 priceRate);

    function getDebtIndexForAsset(
        address _asset
    ) external view returns (uint256 debtIndex);

    function getStabilityRateConfigurationForAsset(
        address _asset
    ) external view returns (StabilityRateConfig memory);

    function kiss() external view returns (address);

    function getLastDebtIndexForAccount(
        address _account,
        address _asset
    ) external view returns (uint128 lastDebtIndex);
}
