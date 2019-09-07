pragma solidity ^0.5.9;

import "../DelightBaseUnitInterface.sol";
import "../Util/SafeMath.sol";

contract DelightArcher is DelightBaseUnitInterface {
	using SafeMath for uint;
	
	Materials private materials = Materials({
		wood : 50,
		stone : 0,
		iron : 100,
		ducat : 100
	});
}