pragma solidity ^0.5.9;

import "../DelightBuildingInterface.sol";
import "../Util/SafeMath.sol";

contract DelightGate is DelightBuildingInterface {
	using SafeMath for uint;
	
	Materials private materials = Materials({
		wood : 100,
		stone : 600,
		iron : 200,
		ducat : 0
	});
}