pragma solidity ^0.5.9;

import "../DelightItem.sol";
import "../Util/SafeMath.sol";

contract DelightCatapult is DelightItem {
	using SafeMath for uint;
	
	constructor() DelightItem() public {
		
		_name = "Delight Catapult";
		_symbol = "DCP";
	}
}