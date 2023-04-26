// SPDX-License-Identifier: MIT
pragma solidity >=0.8.14;
import {EnumerableSet} from "../libs/EnumerableSet.sol";
/// @dev set the initial value to 1 as we do not
/// wanna hinder possible gas refunds by setting it to 0 on exit.

/* -------------------------------------------------------------------------- */
/*                                 Reentrancy                                 */
/* -------------------------------------------------------------------------- */
uint256 constant NOT_ENTERED = 1;
uint256 constant ENTERED = 2;

/* ========================================================================== */
/*                                   STRUCTS                                  */
/* ========================================================================== */

struct FacetAddressAndPosition {
    address facetAddress;
    // position in facetFunctionSelectors.functionSelectors array
    uint96 functionSelectorPosition;
}

struct FacetFunctionSelectors {
    bytes4[] functionSelectors;
    // position of facetAddress in facetAddresses array
    uint256 facetAddressPosition;
}

struct RoleData {
    mapping(address => bool) members;
    bytes32 adminRole;
}

/* -------------------------------------------------------------------------- */
/*                                 Main Layout                                */
/* -------------------------------------------------------------------------- */

struct DiamondState {
    /* -------------------------------------------------------------------------- */
    /*                                   Proxy                                    */
    /* -------------------------------------------------------------------------- */
    /// @notice Maps function selector to the facet address and
    /// the position of the selector in the facetFunctionSelectors.selectors array
    mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;
    /// @notice Maps facet addresses to function selectors
    mapping(address => FacetFunctionSelectors) facetFunctionSelectors;
    /// @notice Facet addresses
    address[] facetAddresses;
    /// @notice ERC165 query implementation
    mapping(bytes4 => bool) supportedInterfaces;
    /* -------------------------------------------------------------------------- */
    /*                               Initialization                               */
    /* -------------------------------------------------------------------------- */
    /// @notice Initialization status
    bool initialized;
    /// @notice Domain field separator
    bytes32 domainSeparator;
    /* -------------------------------------------------------------------------- */
    /*                                  Ownership                                 */
    /* -------------------------------------------------------------------------- */
    /// @notice Current owner of the diamond
    address contractOwner;
    /// @notice Pending new diamond owner
    address pendingOwner;
    /// @notice Storage version
    uint8 storageVersion;
    /// @notice address(this) replacement for FF
    address self;
    /* -------------------------------------------------------------------------- */
    /*                               Access Control                               */
    /* -------------------------------------------------------------------------- */
    mapping(bytes32 => RoleData) _roles;
    mapping(bytes32 => EnumerableSet.AddressSet) _roleMembers;
    /* -------------------------------------------------------------------------- */
    /*                                 Reentrancy                                 */
    /* -------------------------------------------------------------------------- */
    uint256 entered;
}

// Storage position
bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("kresko.diamond.storage");

function ds() pure returns (DiamondState storage state) {
    bytes32 position = DIAMOND_STORAGE_POSITION;
    assembly {
        state.slot := position
    }
}
