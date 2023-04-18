// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@redstone-finance/evm-connector/contracts/data-services/CustomUrlsConsumerBase.sol";

contract CustomUrlsExample is CustomUrlsConsumerBase {
  function getValue() public view returns (uint256) {
    bytes32 dataFeedId = bytes32("0x2bf6f01ff931d99c");
    return getOracleNumericValueFromTxMsg(dataFeedId);
  }
}