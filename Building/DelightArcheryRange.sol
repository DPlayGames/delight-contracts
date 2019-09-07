pragma solidity ^0.5.9;

import "../DelightBuildingInterface.sol";
import "../Util/SafeMath.sol";

contract DelightArcheryRange is DelightBuildingInterface {
	using SafeMath for uint;
	
	Materials private materials = Materials({
		wood : 200,
		stone : 50,
		iron : 200,
		ducat : 200
	});
}