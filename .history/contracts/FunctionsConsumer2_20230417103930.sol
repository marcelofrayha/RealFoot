// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
// 0xeA6721aC65BCeD841B8ec3fc5fEdeA6141a0aDE4 0x01080f oracle address

import {Functions, FunctionsClient} from "./dev/functions/FunctionsClient.sol";

// import "@chainlink/contracts/src/v0.8/dev/functions/FunctionsClient.sol"; // Once published
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

/**
 * @title Functions Consumer contract
 * @notice This contract is a demonstration of using Functions.
 * @notice NOT FOR PRODUCTION USE
 */
contract FunctionsConsumer is FunctionsClient, ConfirmedOwner {
  using Functions for Functions.Request;

  uint public winner;
  uint public winner2;
  uint public winner3;
  bytes32 public latestRequestId;
  bytes public latestResponse;
  string public responseString;
  bytes public latestError;
  address public oraculo;

  event OCRResponse(bytes32 indexed requestId, bytes result, bytes err);

  function bytesToUintArray(bytes memory input) public pure returns (uint[3] memory output) {
      require(input.length == 3, "Input length must be 3 bytes");
      
      assembly {
          let bytePtr := add(input, 32) // skip the length field
          mstore(output, shr(248, mload(bytePtr))) // store the first uint
          mstore(add(output, 32), shr(248, mload(add(bytePtr, 1)))) // store the second uint
          mstore(add(output, 64), shr(248, mload(add(bytePtr, 2)))) // store the third uint
      }
      
      return output;
  }

  function getWinner() internal {
        winner = bytesToUintArray(latestResponse)[0];
        winner2 = bytesToUintArray(latestResponse)[1];
        winner3 = bytesToUintArray(latestResponse)[2];

  }
  function setResponse(bytes memory input) public {
    latestResponse = input;
  }

  /**
   * @notice Executes once when a contract is created to initialize state variables
   *
   * @param oracle - The FunctionsOracle contract
   */
  // https://github.com/protofire/solhint/issues/242
  // solhint-disable-next-line no-empty-blocks
  constructor(address oracle) FunctionsClient(oracle) ConfirmedOwner(msg.sender) {
    oraculo = oracle;
  }

  /**
   * @notice Send a simple request
   *
   * @param source JavaScript source code
   * @param secrets Encrypted secrets payload
   * @param args List of arguments accessible from within the source code
   * @param subscriptionId Funtions billing subscription ID
   * @param gasLimit Maximum amount of gas used to call the client contract's `handleOracleFulfillment` function
   * @return Functions request ID
   */
  function executeRequest(
    string calldata source,
    bytes calldata secrets,
    string[] calldata args,
    uint64 subscriptionId,
    uint32 gasLimit
  ) public onlyOwner returns (bytes32) {
    Functions.Request memory req;
    req.initializeRequest(Functions.Location.Inline, Functions.CodeLanguage.JavaScript, source);
    if (secrets.length > 0) {
      req.addRemoteSecrets(secrets);
    }
    if (args.length > 0) req.addArgs(args);

    bytes32 assignedReqID = sendRequest(req, subscriptionId, gasLimit);
    latestRequestId = assignedReqID;
    return assignedReqID;
  }

  /**
   * @notice Callback that is invoked once the DON has resolved the request or hit an error
   *
   * @param requestId The request ID, returned by sendRequest()
   * @param response Aggregated response from the user code
   * @param err Aggregated error from the user code or from the execution pipeline
   * Either response or error parameter will be set, but never both
   */
  function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
    latestResponse = response;
    latestError = err;
    getWinner();
    emit OCRResponse(requestId, response, err);
  }

  /**
   * @notice Allows the Functions oracle address to be updated
   *
   * @param oracle New oracle address
   */
  function updateOracleAddress(address oracle) public onlyOwner {
    setOracle(oracle);
  }

  function addSimulatedRequestId(address oracleAddress, bytes32 requestId) public onlyOwner {
    addExternalRequest(oracleAddress, requestId);
  }
}
