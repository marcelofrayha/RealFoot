// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract APIConsumer is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    uint256 public winner;
    bytes32 private jobId;
    uint256 private fee;

    event RequestWinner(bytes32 indexed requestId, uint256 winner);

    constructor() ConfirmedOwner(msg.sender) {
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
        setChainlinkOracle(0x20CAc2354359919C15950dEA3033a7712b6eCf8C);
        jobId = "3d2529ce26a74c9d9e593750d94950c9";
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18
    }

    /**
     * Create a Chainlink request to retrieve API response, then find the target
     * data.
     */
    function requestWinner() public returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );

        req.add(
            "get",
            "http://api.football-data.org/v4/competitions/PL/standings?season=2020"
        );

        req.add("path", "season,winner,id"); // Chainlink nodes 1.0.0 and later support this format

        // Sends the request
        return sendChainlinkRequest(req, fee);
    }

    mapping (uint => address) NFTHolder;

    /**
     * Receive the response in the form of uint256
     */
    function fulfill(
        bytes32 _requestId,
        uint256 _winner
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestWinner(_requestId, _winner);
        winner = _winner;
    }

    /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }
    function setWinner(uint id) public {
        winner = id;
    }
}