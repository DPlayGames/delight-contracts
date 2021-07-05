pragma solidity ^0.5.9;

import "../DelightItem.sol";
import "../Util/SafeMath.sol";

contract DelightCatapult is DelightItem {
	using SafeMath for uint;
	
	constructor(address dplayTradingPost) DelightItem(dplayTradingPost) public {
		
		_name = "Delight Catapult";
		_symbol = "DCP";
	}
}