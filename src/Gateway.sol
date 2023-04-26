// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IKresko} from "./interfaces/IKresko.sol";
import {IERC20} from "./vendor/IERC20.sol";

/** 
* @title KreskoGateway
* @author Kresko
* @dev Gateway contract that checks if the gas asset has a wrapper token that is accepted as collateral. If so, wraps msg.value and deposits on behalf of msg.sender as collateral.
*/
contract KreskoGateway {

    // Kresko contract
    IKresko public kresko;

    // Wrapped gas asset
    address public immutable wAsset;

    /**
    * @notice Constructor
    * @param _kresko Kresko contract address
    * @param _wAsset Wrapped gas asset address
    */
    constructor(address _kresko, address _wAsset) {
        kresko = IKresko(_kresko);
        wAsset = _wAsset;
    }
    
    /**
    * @notice Deposits msg.value as collateral on behalf of msg.sender
    */
    function deposit() public payable {
        require(msg.value > 0, "KreskoGateway: No value sent");
        require(kresko.collateralExists(wAsset), "Kresko Collateral does not exist");
        (bool success,) = wAsset.call{value: msg.value}("");
        require(success, "KreskoGateway: Failed to wrap gas asset");
        IERC20(wAsset).approve(address(kresko), msg.value);
        kresko.depositCollateral(msg.sender, wAsset, msg.value);
    }

    receive() external payable {
        deposit();
    }

    fallback() external payable {
        deposit();
    }
}
