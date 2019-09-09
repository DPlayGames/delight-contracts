pragma solidity ^0.5.9;

import "../DelightItem.sol";
import "../Util/SafeMath.sol";

contract DelightCamel is DelightItem {
	using SafeMath for uint;
	
	constructor() DelightItem() public {
		
		_name = "Delight Camel";
		_symbol = "DCM";
	}
}