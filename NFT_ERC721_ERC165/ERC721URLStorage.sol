// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";

abstract contract ERC721URLStorage is ERC721{
    mapping(uint => string) private _tokenURLs;

    function tokenURL(uint tokenId) public view virtual override  _requireMinted(tokenId) returns(string memory){
        string memory _tokenURL = _tokenURLs[tokenId];
        string memory _base = _baseURL();
        
        if(bytes(_base).length == 0) {
            return _tokenURL;
        }
        if(bytes(_tokenURL).length > 0) {
            return string(abi.encodePacked(_base, _tokenURL));
        }

        return super.tokenURL(tokenId);


    }

    function _setTokenURL(uint tokenId, string memory _tokenURL) internal virtual _requireMinted(tokenId){
        _tokenURLs[tokenId] = _tokenURL;

    }

    function _burn(uint tokenId) internal virtual override {
        super._burn(tokenId);

        if(bytes(_tokenURLs[tokenId]).length != 0) {
            delete _tokenURLs[tokenId];
        }
    }
}