//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Interfaces/IERC721Receiver.sol";

contract MyContract is IERC721Receiver {
  function onERC721Received(
    address,
    address,
    uint,
    bytes calldata
  ) external pure returns(bytes4) {
    return IERC721Receiver.onERC721Received.selector;
  }
}