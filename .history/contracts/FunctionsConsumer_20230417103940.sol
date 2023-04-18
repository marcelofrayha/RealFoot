// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import { FunctionsConsumer, ConfirmedOwner } from  "./FunctionsConsumer2.sol";

/// @custom:security-contact marcelofrayha@gmail.com
contract SweepStocks is ERC1155, ERC1155Supply, ConfirmedOwner, FunctionsConsumer {

    uint creationTime;
    uint[3] public payout;
    bool private payoutDefined = false;
    address private _owner; //contract owner - this will be a multisig or zk wallet
    mapping (uint => uint) public mintPrice; //price to create a new NFT, this is handled by the contract
    mapping (uint => mapping (address => uint)) public transferPrice; //price set by the owner of a NFT

    constructor(address oracle) FunctionsConsumer(oracle) payable
        ERC1155("https://ipfs.io/ipfs/QmUNLLsPACCz1vLxQVkXqqLX5R1X345qqfHbsf67hvA3Nn")
    {
        _owner = msg.sender;
        creationTime = block.timestamp;
    }

    function setURI(string memory newuri) external onlyOwner {
        _setURI(newuri);
    }

    //Creates an NFT representing a football team
    function mint(address account, uint256 id, uint256 amount, bytes memory data) payable external {
        require(winner == 0, "Not active");
        require(amount + totalSupply(id) <= 100000, "The NFT reached its cap");
        require(amount <= 20, "You can only mint 20 in the same transaction");
        if (totalSupply(id) == 0) mintPrice[id] = 100;
        require (msg.value >= mintPrice[id]*amount, "Send more money");
        _mint(account, id, amount, data);
        if (!isApprovedForAll(msg.sender, address(this))) setApprovalForAll(address(this), true);
        mintPrice[id] += amount*100;
        // tokenOwners[id][account] += amount;
    }

    //Creates a batch of NFTs
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        payable
        external
    {
        require(winner == 0, "Not active");
        for (uint i = 0; i < ids.length; i++) {
            require(amounts[i] + totalSupply(ids[i]) <= 100000, "The NFT reached its cap");
            require(amounts[i] <= 20, "You can only mint 20 in the same transaction");
            if (totalSupply(ids[i]) == 0) mintPrice[ids[i]] = 100;
           require (msg.value >= mintPrice[ids[i]]*amounts[i], "Send more money");
            mintPrice[ids[i]] += amounts[i]*100;
            // tokenOwners[ids[i]][to] += amounts[i];
        }
        _mintBatch(to, ids, amounts, data);
        if (!isApprovedForAll(msg.sender, address(this))) setApprovalForAll(address(this), true);
    }

    //Allow destroying the contract after 400 days of its creation 
    function destroy() public {
        require(block.timestamp > creationTime + 400 days);
        payable(_owner).transfer(address(this).balance);
        winner = 100000;
    }
    
    //Allow users to set a price for its NFT
    function setTokenPrice(uint id, uint price ) external {
        require (balanceOf(msg.sender, id) > 0, "You don't have this NFT");
        transferPrice[id][msg.sender] = price;
    }

    //Allow user to buy someone else's NFT
    function buyToken(uint id, uint amount, address nftOwner) payable public {
        require(winner == 0, "Not active");
        require(msg.value == transferPrice[id][nftOwner] * amount, "The value sent must match the price");
        require(amount <= balanceOf(nftOwner, id), "You can't buy that much");
        require(winner == 0, "We already have a winner, the market is closed");
        payable(nftOwner).transfer(transferPrice[id][nftOwner]*999/1000);
        payable(_owner).transfer(transferPrice[id][nftOwner]*5/10000);
        (bool success, ) = address(this).call(abi.encodeWithSignature("safeTransferFrom(address,address,uint256,uint256,bytes)", nftOwner, msg.sender, id, amount, ""));
        require(success, "Function call failed");
    }

    /*Calculate how much each NFT was awarded by the end of the season 
    It is called when the first user calls a payWinner function*/
    function calculatePayout() private {
        uint balance = address(this).balance;
        payout[0] = balance / 4; //payout for the 1st place
        payout[1] = balance / 2; //payout for the 10th place
        payout[2] = balance / 4; //payout for the 17th place
    }

    //Pays the holder of a NFT representing the champion the 10th place and the 17th place
    function payWinner() payable public {
        if (payoutDefined == false) calculatePayout();
        require (winner != 0, "There is no winner");
        require (balanceOf(msg.sender, winner) != 0 || balanceOf(msg.sender, winner2) != 0 || balanceOf(msg.sender, winner3) != 0, "You don't have this NFT");
        address garbage = 0x8431717927C4a3343bCf1626e7B5B1D31E240406;
        if (balanceOf(msg.sender, winner) != 0) {
        uint balance = balanceOf(msg.sender, winner);
        _safeTransferFrom(msg.sender, garbage, winner, balance, "");
        uint supply = totalSupply(winner);
        payable(msg.sender).transfer(payout[0] * balance / supply);
        }
        if (balanceOf(msg.sender, winner2) != 0) {
        uint balance = balanceOf(msg.sender, winner2);
        _safeTransferFrom(msg.sender, garbage, winner2, balance, "");
        uint supply = totalSupply(winner2);
        payable(msg.sender).transfer(payout[1] * balance / supply);
        }
        if (balanceOf(msg.sender, winner3) != 0) {
        uint balance = balanceOf(msg.sender, winner3);
        _safeTransferFrom(msg.sender, garbage, winner3, balance, "");
        uint supply = totalSupply(winner3);
        payable(msg.sender).transfer(payout[2] * balance / supply);
        }
        payoutDefined = true;
    }

    //This is an override function to update our owners' list
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal override {
        super._safeTransferFrom(
             from,
             to,
             id,
             amount,
             data
          );
    }
    
    // The following function is override required by Solidity.
    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}