pragma solidity ^0.5.9;

import "../DelightItemInterface.sol";
import "../Standard/ERC20.sol";
import "../Standard/ERC165.sol";
import "../Util/NetworkChecker.sol";
import "../Util/SafeMath.sol";

contract DelightCamel is DelightItemInterface, ERC20, ERC165, NetworkChecker {
	using SafeMath for uint;
}