pragma solidity ^0.5.9;

import "../DelightBuildingInterface.sol";
import "../Util/SafeMath.sol";

contract DelightWall is DelightBuildingInterface {
	using SafeMath for uint;
	
	Materials private materials = Materials({
		wood : 0,
		stone : 400,
		iron : 0,
		ducat : 0
	});
}