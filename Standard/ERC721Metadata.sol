pragma solidity ^0.5.9;

interface ERC721Metadata /* is ERC721 */ {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}