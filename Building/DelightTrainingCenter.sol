pragma solidity ^0.5.9;

import "../DelightBuildingInterface.sol";
import "../Util/SafeMath.sol";

contract DelightTrainingCenter is DelightBuildingInterface {
	using SafeMath for uint;
	
	Materials private materials = Materials({
		wood : 300,
		stone : 50,
		iron : 100,
		ducat : 100
	});
}