// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

library StringUtils {
    function concat(string memory a, string memory b) internal pure returns (string memory) {
        return string(abi.encodePacked(a, b));
    }
}

contract APIConsumer is ChainlinkClient, ConfirmedOwner {
    using StringUtils for string;
    using Chainlink for Chainlink.Request;

    uint256 public winner;
    uint256 public winner2;
    uint256 public winner3;

    bytes32 private jobId;
    uint256 private fee;
    string private URL;
    string public league;
    event RequestWinner(bytes32 indexed requestId, uint256 winner, uint256 winner2, uint256 winner3);

    constructor(string memory _league) ConfirmedOwner(msg.sender) {
        string memory baseURL = "http://api.football-data.org/v4/competitions/";
        string memory endpoint = "/standings"; 
        league = _league;
        URL = baseURL.concat(league).concat(endpoint);
        setChainlinkOracle(0x7ca7215c6B8013f249A195cc107F97c4e623e5F5); //Polygon Oracle run by OracleSpace Labs
        // setChainlinkOracle(0xC29bC7fc567966b84E54093e6AfF0476d5684d3e); //Polygon oracle (my own)
        // setChainlinkToken(0xE2e73A1c69ecF83F464EFCE6A5be353a37cA09b2); //Polygon LINK Token
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB); //Goerli LINK Token
        //jobId = "3d2529ce26a74c9d9e593750d94950c9"; //single response job
        jobId = "cd3a5f8dcac245e9a3ff58d59b445595"; //multi response job
        fee = (1 * LINK_DIVISIBILITY) / 20; // 0,05 * 10**18
    }

    /**
     * Create a Chainlink request to retrieve API response, then find the target
     * data.
     */
    function requestWinner() public virtual returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfillOracleRequest.selector
        );

        req.add(
            "get",
            URL
        );

        req.add(
            "league",
            league
        );


        // Sends the request
        return sendChainlinkRequest(req, fee);
    }

    mapping (uint => address) NFTHolder;

    /**
     * Receive the response in the form of uint256
     */
    function fulfillOracleRequest(
        bytes32 _requestId,
        uint256 _winner,
        uint _winner2,
        uint _winner3
    ) public virtual recordChainlinkFulfillment(_requestId) {
        emit RequestWinner(_requestId, _winner, _winner2, _winner3);
        winner = _winner;
        winner2 = _winner2;
        winner3 = _winner3;
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

    function setWinner2(uint id) public {
        winner2 = id;
    }
    function setWinner3(uint id) public {
        winner3 = id;
    }
}
