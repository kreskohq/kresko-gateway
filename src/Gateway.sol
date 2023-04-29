// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IKresko} from "./interfaces/IKresko.sol";
import {IWAsset} from "./interfaces/IWAsset.sol";

/** 
* @title KreskoGateway
* @author Kresko
* @dev Gateway contract that checks if the gas asset has a wrapper token that is accepted as collateral. If so, wraps msg.value and deposits on behalf of msg.sender as collateral.
*/
contract KreskoGateway {

    // Kresko contract
    IKresko public immutable kresko;

    // Wrapped gas asset
    IWAsset public immutable wAsset;

    /* -------------------------------------------------------------------------- */
    /*                                   EVENTS                                   */
    /* -------------------------------------------------------------------------- */

    /// @notice emitted when a user deposits collateral
    event Deposit(address indexed account, uint256 amount);

    /// @notice emitted when a user withdraw collateral
    event Withdraw(address indexed account, uint256 amount);

    /**
    * @dev Sets the Kresko address and the wrapped gas token address. Infinite
    approves kresko to transfer wrapped gas token.
    * @param _kresko Addess of Kresko contract 
    * @param _wAsset Address of Wrapped gas asset
    */
    constructor(address _kresko, address _wAsset) {
        kresko = IKresko(_kresko);
        wAsset = IWAsset(_wAsset);

        // Infinite approve kresko to transfer wrapped gas token.
        wAsset.approve(address(kresko), type(uint256).max);
    }
    
    /**
    * @dev Deposits msg.value as collateral on behalf of _account
    * @param _account Address of the user to whom the collateral would be deposited
    */
    function deposit(address _account) external payable {
        require(msg.value > 0, "KreskoGateway: No value sent");
        require(kresko.collateralExists(address(wAsset)), "Kresko Collateral does not exist");
        
        wAsset.deposit{value: msg.value}();
        kresko.depositCollateral(_account, address(wAsset), msg.value);

        emit Deposit(_account, msg.value);
    }

    /**
     * @dev withdraws the wAsset collateral of msg.sender.
     * @param _to address of the user who will receive native gas token
     * @param _amount amount of wAsset to withdraw and receive native gas token
     */
    function withdraw(
        address _to,
        uint256 _amount
    ) external {
        uint cIndex = kresko.getDepositedCollateralAssetIndex(msg.sender, address(wAsset));
        kresko.withdrawCollateral(msg.sender, address(wAsset), _amount, cIndex);
        
        wAsset.transferFrom(msg.sender, address(this), _amount);
        wAsset.withdraw(_amount);
        
        (bool success, ) = _to.call{value: _amount}(new bytes(0));
        require(success, 'TRANSFER_FAILED');

        emit Withdraw(_to, _amount);
    }

    /**
    * @dev Only wAsset contract is allowed to transfer gas token here. Prevent other
    addresses to send gas token to this contract.
    */
    receive() external payable {
        require(msg.sender == address(wAsset), 'Receive not allowed');
    }

    /**
    * @dev Revert fallback calls
    */
    fallback() external payable {
      revert('Fallback not allowed');
    }
}
