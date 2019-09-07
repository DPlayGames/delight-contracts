pragma solidity ^0.5.9;

import "../DelightBaseUnitInterface.sol";
import "../Util/SafeMath.sol";

contract DelightKnight is DelightBaseUnitInterface {
	using SafeMath for uint;
	
	Materials private materials = Materials({
		wood : 0,
		stone : 0,
		iron : 300,
		ducat : 1000
	});
}