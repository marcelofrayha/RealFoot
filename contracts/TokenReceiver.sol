// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

contract TokenReceiver is IERC1155Receiver {
    bytes4 private constant _INTERFACE_ID_ERC1155_RECEIVER = 0xf23a6e61;
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    function supportsInterface(bytes4 interfaceID) external pure override returns (bool) {
        return interfaceID == _INTERFACE_ID_ERC165 || interfaceID == _INTERFACE_ID_ERC1155_RECEIVER;
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external pure override returns (bytes4) {
        // Your custom logic here for handling the received ERC1155 token
        // Note that this function must return the bytes4 value 0xf23a6e61, which is the interface ID for ERC1155Receiver.onERC1155Received
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external pure override returns (bytes4) {
        // Your custom logic here for handling the received batch of ERC1155 tokens
        // Note that this function must return the bytes4 value 0xbc197c81, which is the interface ID for ERC1155Receiver.onERC1155BatchReceived
        return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
    }
}
