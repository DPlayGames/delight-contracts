pragma solidity ^0.5.9;

import "../DelightBuildingInterface.sol";
import "../Util/SafeMath.sol";

contract DelightHQ is DelightBuildingInterface {
	using SafeMath for uint;
	
	Materials private materials = Materials({
		wood : 400,
		stone : 0,
		iron : 0,
		ducat : 100
	});
}