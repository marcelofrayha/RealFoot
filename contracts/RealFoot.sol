// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import { APIConsumer, ConfirmedOwner } from  "./ChainlinkConsumer.sol";


/// @custom:security-contact marcelofrayha@gmail.com
contract RealFoot is ERC1155, ERC1155Supply, ConfirmedOwner, ERC1155Burnable, APIConsumer {

    address _owner;
    address[] public listOfOwners;
    uint[] public idsList;
    
    mapping (address => bool) ownerOnList;
    mapping (address => uint[]) public ownerWallet;
    mapping (uint => uint) public mintPrice;
    mapping (uint => mapping(address => uint)) public transferPrice;
    mapping (uint => address[]) public tokenOwners; 

    constructor() payable
        ERC1155("https://ipfs.io/ipfs/QmUNLLsPACCz1vLxQVkXqqLX5R1X345qqfHbsf67hvA3Nn")
    {
        _owner = msg.sender;
    }

    function setURI(string memory newuri) external onlyOwner {
        _setURI(newuri);
    }
    // Updates the list of all the owners a NFT has
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
    
    // Updates the list of all NFTs owned by an account
    function updateWallet (address account, uint id) private {
        bool inTheList = false;
        for (uint i = 0; i < ownerWallet[account].length; i++) {
            if (ownerWallet[account][i] == id) inTheList = true;
            if (balanceOf(account, id) == 0) {
                ownerWallet[account][i] = ownerWallet[account][ownerWallet[account].length - 1];
                ownerWallet[account].pop();
                inTheList = false;
            }
        }
        if (!inTheList) ownerWallet[account].push(id); 
    }

    // Updates the list of all minted NFTs
    function updateIdsList (uint id) private {
        bool inTheList = false;
        for (uint i = 0; i < idsList.length; i++) {
            if (idsList[i] == id) inTheList = true;
        }
        if (!inTheList) idsList.push(id); 
    }
    //Returns all the owners of a NFT
    function getOwnersList (uint id) public view returns (address[] memory) {
        return tokenOwners[id];
    }

    function getOwnerWallet (address account) public view returns (uint[] memory) {
        return ownerWallet[account];
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data) payable external {
        require(amount + totalSupply(id) <= 100000);
        require(amount <= 20);
        if (totalSupply(id) == 0) mintPrice[id] = 100;
        require (msg.value >= mintPrice[id]*amount);
        updateOwnersList(id, account);
        _mint(account, id, amount, data);
        if (!isApprovedForAll(msg.sender, address(this))) setApprovalForAll(address(this), true);
        mintPrice[id] += amount*100;
        updateIdsList(id);
        updateWallet(account, id);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        payable
        external
    {
        for (uint i = 0; i < ids.length; i++) {
            require(amounts[i] + totalSupply(ids[i]) <= 100000);
            require(amounts[i] <= 20);
            if (totalSupply(ids[i]) == 0) mintPrice[ids[i]] = 100;
           require (msg.value >= mintPrice[ids[i]]*amounts[i]);
            mintPrice[ids[i]] += amounts[i]*100;
            updateOwnersList(ids[i], to);
            updateIdsList(ids[i]);
            updateWallet(to, ids[i]);

        }
        _mintBatch(to, ids, amounts, data);
        if (!isApprovedForAll(msg.sender, address(this))) setApprovalForAll(address(this), true);
    }

    // The following function is override required by Solidity.

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function payWinner() payable external {
        require (winner != 0, "There is no winner");
        require (exists(winner), "No one minted the winner's NFT");
        uint supply = totalSupply(winner);
        uint value = address(this).balance;
        for (uint i = 0; i < getOwnersList(winner).length; i++) {
            address nftOwner = tokenOwners[winner][i];
            uint balance = balanceOf(nftOwner, winner);
            payable(nftOwner).transfer(value * balance / supply);
        }
    }
address[] public x;
    function resetState() public {
        winner = 0;
        for (uint i = 0; i < idsList.length; i++) {
            mintPrice[idsList[i]] = 0;
            address[] memory _tokenOwner = tokenOwners[idsList[i]];
            x = _tokenOwner;
            for (uint j = 0; j < _tokenOwner.length; j++) {
             //   ammounts[j] = balanceOf(tokenOwners[idsList[i]][j],idsList[i]);
                if(!ownerOnList[tokenOwners[idsList[i]][j]]) {
                    listOfOwners.push(tokenOwners[idsList[i]][j]);
                    ownerOnList[tokenOwners[idsList[i]][j]] = true;
                }
            }
            for (uint j = 0; j < listOfOwners.length; j++) {
                uint walletSize = getOwnerWallet(listOfOwners[j]).length;
                address[] memory batchParam = new address[](walletSize);
                for (uint z = 0; z < walletSize; z++) {
                    batchParam[z] = listOfOwners[j];
                }
                uint[] memory ammounts = balanceOfBatch(batchParam, getOwnerWallet(listOfOwners[j]));
                (bool success, ) = address(this)
                .call(abi.encodeWithSignature("burnBatch(address,uint[],uint[])", listOfOwners[j], getOwnerWallet(listOfOwners[j]), ammounts, ""));
                require(success, "Function call failed");
                delete ownerWallet[listOfOwners[j]];
                delete ownerOnList[listOfOwners[j]];
            }
            delete tokenOwners[idsList[i]];
        }
        delete listOfOwners;
        delete idsList;
    }

    function setTokenPrice(uint id, uint price ) external {
        require (balanceOf(msg.sender, id) > 0);
        transferPrice[id][msg.sender] = price;
    }

    function buyToken(uint id, uint amount, address nftOwner) payable public {
        require(msg.value == transferPrice[id][nftOwner]);
        require(amount <= balanceOf(nftOwner, id));
        require(winner == 0, "We already have a winner, the market is closed");
        payable(nftOwner).transfer(transferPrice[id][nftOwner]*999/1000);
        payable(_owner).transfer(transferPrice[id][nftOwner]*5/10000);
        (bool success, ) = address(this).call(abi.encodeWithSignature("safeTransferFrom(address,address,uint256,uint256,bytes)", nftOwner, msg.sender, id, amount, ""));
        require(success, "Function call failed");
    }

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
        updateWallet(to, id);
        updateWallet(from, id);
    }
}
