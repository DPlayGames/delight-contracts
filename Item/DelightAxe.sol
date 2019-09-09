pragma solidity ^0.5.9;

import "../DelightItem.sol";
import "../Util/SafeMath.sol";

contract DelightAxe is DelightItem {
	using SafeMath for uint;
	
	constructor() DelightItem() public {
		
		_name = "Delight Axe";
		_symbol = "DA";
	}
}