// SPDX-License-Identifier: MIT
pragma solidity >=0.8.14;
import {IAccessControlEnumerableUpgradeable} from "../vendor/IAccessControl.sol";
import {IERC165} from "../vendor/IERC165.sol";
import {IERC20} from "../vendor/IERC20.sol";
import {IKreskoAssetIssuer} from "./IKreskoAssetIssuer.sol";

interface IKreskoAssetAnchor is
    IKreskoAssetIssuer,
    IERC20,
    IAccessControlEnumerableUpgradeable,
    IERC165
{
    function asset() external view returns (address);

    function deposit(uint256, address) external returns (uint256);

    function withdraw(uint256, address, address) external returns (uint256);

    function initialize(
        address _asset,
        string memory _name,
        string memory _symbol,
        address _admin
    ) external;

    function maxDeposit(address) external view returns (uint256);

    function maxMint(address) external view returns (uint256);

    function maxRedeem(address owner) external view returns (uint256);

    function maxWithdraw(address owner) external view returns (uint256);

    function mint(
        uint256 _shares,
        address _receiver
    ) external returns (uint256 assets);

    function previewDeposit(uint256 assets) external view returns (uint256);

    function previewMint(uint256 shares) external view returns (uint256);

    function previewRedeem(uint256 shares) external view returns (uint256);

    function previewWithdraw(uint256 assets) external view returns (uint256);

    function totalAssets() external view returns (uint256);

    function reinitializeERC20(
        string memory _name,
        string memory _symbol,
        uint8 _version
    ) external;
}
