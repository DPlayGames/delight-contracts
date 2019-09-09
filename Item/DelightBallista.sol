pragma solidity ^0.5.9;

import "../DelightItem.sol";
import "../Util/SafeMath.sol";

contract DelightBallista is DelightItem {
	using SafeMath for uint;
	
	constructor() DelightItem() public {
		
		_name = "Delight Ballista";
		_symbol = "DB";
	}
}