pragma solidity ^0.5.9;

import "./DelightInterface.sol";
import "./Util/SafeMath.sol";

contract DelightBase is DelightInterface {
	using SafeMath for uint;
	
	// 지형의 범위
	uint constant private COL_RANGE = 100;
	uint constant private ROW_RANGE = 100;
	
	// 범위를 체크합니다.
	modifier checkRange(uint col, uint row) {
		require(col < COL_RANGE && row < ROW_RANGE);
		_;
	}
	
	// 기사
	uint constant private ARMY_KNIGHT = 0;
	
	// 근거리병
	uint constant private ARMY_SWORDSMAN = 1;
	uint constant private ARMY_AXEMAN = 2;
	uint constant private ARMY_SPEARMAN = 3;
	uint constant private ARMY_SHIELDMAN = 4;
	uint constant private ARMY_SPY = 5;
	
	// 원거리병
	uint constant private ARMY_ARCHER = 6;
	uint constant private ARMY_CROSSBOWMAN = 7;
	uint constant private ARMY_BALLISTA = 8;
	uint constant private ARMY_CATAPULT = 9;
	
	// 기마병
	uint constant private ARMY_CAVALY = 10;
	uint constant private ARMY_CAMELY = 11;
	uint constant private ARMY_WAR_ELEPHANT = 12;
	
	Building[] private buildings;
	Army[] private armies;
	
	mapping(uint => mapping(uint => uint)) private positionToBuildingId;
	mapping(uint => mapping(uint => uint[])) private positionToArmyIds;
}