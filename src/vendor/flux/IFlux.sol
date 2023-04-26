// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(
        uint80 _roundId
    )
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            bool marketOpen,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            bool marketOpen,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

interface AggregatorInterface {
    function latestAnswer() external view returns (int256);

    function latestTimestamp() external view returns (uint256);

    function latestMarketOpen() external view returns (bool);

    function latestRound() external view returns (uint256);

    function getAnswer(uint256 roundId) external view returns (int256);

    function getTimestamp(uint256 roundId) external view returns (uint256);

    function getMarketOpen(uint256 roundId) external view returns (bool);

    event AnswerUpdated(
        int256 indexed current,
        bool marketOpen,
        uint256 indexed roundId,
        uint256 updatedAt
    );
    event NewRound(
        uint256 indexed roundId,
        address indexed startedBy,
        uint256 startedAt
    );
}

interface AggregatorV2V3Interface is
    AggregatorInterface,
    AggregatorV3Interface
{}

/**
 * @dev EIP2362 Interface for pull oracles
 * https://github.com/tellor-io/EIP-2362
 */
interface IERC2362 {
    /**
     * @dev Exposed function pertaining to EIP standards
     * @param _id bytes32 ID of the query
     * @return int,uint,uint returns the value, timestamp, and status code of query
     */
    function valueFor(
        bytes32 _id
    ) external view returns (int256, uint256, uint256);
}
