pragma solidity ^0.5.9;

interface ERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}