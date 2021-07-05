pragma solidity ^0.5.9;

import "../DelightItem.sol";
import "../Util/SafeMath.sol";

contract DelightHood is DelightItem {
	using SafeMath for uint;
	
	constructor(address dplayTradingPost) DelightItem(dplayTradingPost) public {
		
		_name = "Delight Hood";
		_symbol = "DH";
	}
}