pragma solidity ^0.5.9;

import "./DelightBase.sol";
import "./Util/SafeMath.sol";

contract DelightWorld is DelightBase {
	using SafeMath for uint;
	
	// 지형의 범위
	uint constant internal COL_RANGE = 100;
	uint constant internal ROW_RANGE = 100;
	
	// 한 위치에 존재할 수 있는 최대 유닛 수
	uint constant internal MAX_POSITION_UNIT_COUNT = 50;
	
}