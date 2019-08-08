pragma solidity ^0.5.9;

import "./DelightInterface.sol";
import "./Util/SafeMath.sol";

contract DelightBase is DelightInterface {
	using SafeMath for uint;
	
	// 지형의 범위
	uint constant private COL_RANGE = 100;
	uint constant private ROW_RANGE = 100;
	
	// 기사
	uint constant private ARMY_KNIGHT = 0;
	
	// 근거리병
	uint constant private ARMY_SWORDSMAN = 0;
	uint constant private ARMY_AXEMAN = 1;
	uint constant private ARMY_SPEARMAN = 0;
	uint constant private ARMY_SHIELDMAN = 1;
	uint constant private ARMY_SPY = 1;
	
	// 원거리병
	uint constant private ARMY_ARCHER = 1;
	uint constant private ARMY_CROSSBOWMAN = 1;
	uint constant private ARMY_BALLISTA = 1;
	uint constant private ARMY_CATAPULT = 1;
	
	// 기마병
	uint constant private ARMY_CAVALY = 1;
	uint constant private ARMY_CAMELY = 1;
	uint constant private ARMY_WAR_ELEPHANT = 1;
	
	Building[] private buildings;
	Army[] private armies;
	
	mapping(uint => mapping(uint => uint)) private positionToBuildingId;
	mapping(uint => mapping(uint => uint[])) private positionToArmyIds;
}