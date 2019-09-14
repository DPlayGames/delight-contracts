pragma solidity ^0.5.9;

import "./DelightSub.sol";
import "./Util/SafeMath.sol";

// 전투 관련 처리
contract DelightBattle is DelightSub {
	using SafeMath for uint;
	
	// 기사의 기본 버프
	uint constant internal KNIGHT_DEFAULT_BUFF_HP = 10;
	uint constant internal KNIGHT_DEFAULT_BUFF_DAMAGE = 5;
	
}