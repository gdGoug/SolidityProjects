// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721URLStorage.sol";

contract Token is ERC721, ERC721Enumerable, ERC721URLStorage {
    address public owner;
    uint currentTokenId;

    constructor() ERC721("NFT_Token", "NFT"){
        owner = msg.sender;
    }

    function safeMint(address to, string calldata tokenId) public {
        require(owner == msg.sender, "not an owner");

        _safeMint(to, currentTokenId);
        _setTokenURL(currentTokenId, tokenId);

        currentTokenId++;
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns(bool){
        return super.supportsInterface(interfaceId);
    }

    function _baseURL() internal  pure override returns(string memory) {
        return "ipfs://";
    }

    function _burn(uint tokenId) internal override(ERC721, ERC721URLStorage){
        super._burn(tokenId);
    }

    function tokenURL(uint tokenId) public view override(ERC721, ERC721URLStorage) returns(string memory){
        return super.tokenURL(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint tokenId) internal override(ERC721, ERC721Enumerable){
        super._beforeTokenTransfer(from, to, tokenId);
    }

    

}