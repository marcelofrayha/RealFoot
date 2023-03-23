// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import { APIConsumer, ConfirmedOwner } from  "./ChainlinkConsumer.sol";


/// @custom:security-contact marcelofrayha@gmail.com
contract SweepStocks is ERC1155, ERC1155Supply, ConfirmedOwner, APIConsumer {

    uint creationTime;
    uint[3] public payout;
    bool private payoutDefined = false;
    address private _owner;
    mapping (uint => uint) public mintPrice;
    mapping (uint => mapping(address => uint)) public transferPrice;
    mapping (uint => address[]) public tokenOwners; 
    // These variables can be used to implement a reset state function
    // uint[] public idsList;
    // address[] public listOfOwners;
    // mapping (address => bool) public ownerOnList;
    // mapping (address => uint[]) public ownerWallet;

    constructor(string memory _league) APIConsumer(_league) payable
        ERC1155("https://ipfs.io/ipfs/QmUNLLsPACCz1vLxQVkXqqLX5R1X345qqfHbsf67hvA3Nn")
    {
        _owner = msg.sender;
        creationTime = block.timestamp;
    }

    function setURI(string memory newuri) external onlyOwner {
        _setURI(newuri);
    }
    // Updates the list of all the owners of a NFT 
    function updateOwnersList (uint id, address account) private {
        bool inTheList = false;
        for (uint i = 0; i < tokenOwners[id].length; i++) {
            if (tokenOwners[id][i] == account) inTheList = true;
            if (balanceOf(tokenOwners[id][i], id) == 0) {
                tokenOwners[id][i] = tokenOwners[id][tokenOwners[id].length - 1];
                tokenOwners[id].pop();
            }
        }
        if (!inTheList) tokenOwners[id].push(account); 
    }

    // Updates the list of all NFTs owned by an account - Only required to reset the contract
    // function updateWallet (address account, uint id) private {
    //     bool inTheList = false;
    //     for (uint i = 0; i < ownerWallet[account].length; i++) {
    //         if (ownerWallet[account][i] == id) inTheList = true;
    //         if (balanceOf(account, id) == 0) {
    //             ownerWallet[account][i] = ownerWallet[account][ownerWallet[account].length - 1];
    //             ownerWallet[account].pop();
    //             inTheList = false;
    //         }
    //     }
    //     if (!inTheList) ownerWallet[account].push(id); 
    // }

    // Updates the list of all minted NFTs - Only required to reset the contract
    // function updateIdsList (uint id) private {
    //     bool inTheList = false;
    //     for (uint i = 0; i < idsList.length; i++) {
    //         if (idsList[i] == id) inTheList = true;
    //     }
    //     if (!inTheList) idsList.push(id); 
    // }

    // function getOwnerWallet (address account) public view returns (uint[] memory) {
    //     return ownerWallet[account];
    // }

    //Returns all the owners of a NFT
    function getOwnersList (uint id) public view returns (address[] memory) {
        return tokenOwners[id];
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data) payable external {
        require(winner == 0, "Not active");
        require(amount + totalSupply(id) <= 100000, "The NFT reached its cap");
        require(amount <= 20, "You can only mint 20 in the same transaction");
        if (totalSupply(id) == 0) mintPrice[id] = 100;
        require (msg.value >= mintPrice[id]*amount, "Send more money");
        _mint(account, id, amount, data);
        if (!isApprovedForAll(msg.sender, address(this))) setApprovalForAll(address(this), true);
        mintPrice[id] += amount*100;
        updateOwnersList(id, account);
        // updateIdsList(id);
        // updateWallet(account, id);
    }

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
            updateOwnersList(ids[i], to);
            // updateIdsList(ids[i]);
            // updateWallet(to, ids[i]);

        }
        _mintBatch(to, ids, amounts, data);
        if (!isApprovedForAll(msg.sender, address(this))) setApprovalForAll(address(this), true);
    }
    function destroy() public {
        require(block.timestamp > creationTime + 400 days);
        payable(_owner).transfer(address(this).balance);
        winner = 100000;
    }
    
    function setTokenPrice(uint id, uint price ) external {
        require (balanceOf(msg.sender, id) > 0, "You don't have this NFT");
        transferPrice[id][msg.sender] = price;
    }

    function buyToken(uint id, uint amount, address nftOwner) payable public {
        require(winner == 0, "Not active");
        require(msg.value == transferPrice[id][nftOwner], "The value sent must match the price");
        require(amount <= balanceOf(nftOwner, id), "You can't buy that much");
        require(winner == 0, "We already have a winner, the market is closed");
        payable(nftOwner).transfer(transferPrice[id][nftOwner]*999/1000);
        payable(_owner).transfer(transferPrice[id][nftOwner]*5/10000);
        (bool success, ) = address(this).call(abi.encodeWithSignature("safeTransferFrom(address,address,uint256,uint256,bytes)", nftOwner, msg.sender, id, amount, ""));
        require(success, "Function call failed");
        updateOwnersList(id, msg.sender);
    }

    function calculatePayout() private {
        uint balance = address(this).balance;
        payout[0] = balance / 4;
        payout[1] = balance / 2;
        payout[2] = balance / 4;
    }

    function payWinner() payable public {
        if (payoutDefined == false) calculatePayout();
        require (winner != 0, "There is no winner");
        require (balanceOf(msg.sender, winner) != 0, "You don't have this NFT");
        uint balance = balanceOf(msg.sender, winner);
        _safeTransferFrom(msg.sender, 0x8431717927C4a3343bCf1626e7B5B1D31E240406, winner, balance, "");
        updateOwnersList(winner, 0x8431717927C4a3343bCf1626e7B5B1D31E240406);
        uint supply = totalSupply(winner);
        payable(msg.sender).transfer(payout[0] * balance / supply);
        payoutDefined = true;

        // uint supply2 = totalSupply(winner2);
        // uint supply3 = totalSupply(winner3);
        // for (uint i = 0; i < getOwnersList(winner).length; i++) {
        //     address nftOwner = tokenOwners[winner][i];
        //     uint balance = balanceOf(nftOwner, winner);
        //     payable(nftOwner).transfer(value * balance / supply);
        // }
        // for (uint i = 0; i < getOwnersList(winner2).length; i++) {
        //     address nftOwner = tokenOwners[winner2][i];
        //     uint balance = balanceOf(nftOwner, winner2);
        //     payable(nftOwner).transfer(value * balance / supply2);
        // }
        // for (uint i = 0; i < getOwnersList(winner3).length; i++) {
        //     address nftOwner = tokenOwners[winner3][i];
        //     uint balance = balanceOf(nftOwner, winner3);
        //     payable(nftOwner).transfer(value * balance / supply3);
        // }
    }

    function payWinner2() payable public {
        if (payoutDefined == false) calculatePayout();
        require (winner2 != 0, "There is no winner");
        require (balanceOf(msg.sender, winner2) != 0, "You don't have this NFT");
        uint balance = balanceOf(msg.sender, winner2);
        _safeTransferFrom(msg.sender, 0x8431717927C4a3343bCf1626e7B5B1D31E240406, winner2, balance, "");
        updateOwnersList(winner2, 0x8431717927C4a3343bCf1626e7B5B1D31E240406);
        uint supply = totalSupply(winner2);
        payable(msg.sender).transfer(payout[1] * balance / supply);
        payoutDefined = true;
    }

    function payWinner3() payable public {
        if (payoutDefined == false) calculatePayout();
        require (winner3 != 0, "There is no winner");
        require (balanceOf(msg.sender, winner3) != 0, "You don't have this NFT");
        uint balance = balanceOf(msg.sender, winner3);
        _safeTransferFrom(msg.sender, 0x8431717927C4a3343bCf1626e7B5B1D31E240406, winner3, balance, "");
        updateOwnersList(winner3, 0x8431717927C4a3343bCf1626e7B5B1D31E240406);
        uint supply = totalSupply(winner3);
        payable(msg.sender).transfer(payout[2] * balance / supply);
        payoutDefined = true;
    }

    // function updateListOfOwners () public {
    //     for (uint i = 0; i < idsList.length; i++) {
    //         mintPrice[idsList[i]] = 0;
    //         for (uint j = 0; j < tokenOwners[idsList[i]].length; j++) {
    //             address ownerAddress = tokenOwners[idsList[i]][j];
    //             if(ownerOnList[ownerAddress] != true) {
    //                 listOfOwners.push(ownerAddress);
    //                 ownerOnList[ownerAddress] = true;
    //             }
    //         }
    //         // delete tokenOwners[idsList[i]];
    //     }    
    // }

    // function resetState() public {
    //     winner = 0;
    //         for (uint j = 0; j < listOfOwners.length; j++) {
    //             uint walletSize = getOwnerWallet(listOfOwners[j]).length;
    //             address[] memory batchParam = new address[](walletSize);
    //             uint[] memory ammounts = new uint[](walletSize);
    //             for (uint z = 0; z < walletSize; z++) {
    //                 batchParam[z] = listOfOwners[j];
    //             }
    //             ammounts = balanceOfBatch(batchParam, getOwnerWallet(listOfOwners[j]));
    //             (bool success, ) = address(this)
    //             .call(abi.encodeWithSignature("burnBatch(address,uint[],uint[])", listOfOwners[j], getOwnerWallet(listOfOwners[j]), ammounts, ""));
    //             require(success, "Function call failed");
    //             delete ownerWallet[listOfOwners[j]];
    //             delete ownerOnList[listOfOwners[j]];
    //         }
        
    //     delete listOfOwners;
    //     delete idsList;
    // }

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
        updateOwnersList(id, to);
        // updateWallet(to, id);
        // updateWallet(from, id);
    }
    // The following function is override required by Solidity.

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}