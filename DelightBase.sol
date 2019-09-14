pragma solidity ^0.5.9;

contract DelightBase {
	
	// 지형의 범위
	uint constant internal COL_RANGE = 100;
	uint constant internal ROW_RANGE = 100;
	
	// 건물
	uint constant internal BUILDING_HQ				= 0;
	uint constant internal BUILDING_TRAINING_CENTER	= 1;
	uint constant internal BUILDING_ARCHERY_RANGE	= 2;
	uint constant internal BUILDING_STABLE			= 3;
	uint constant internal BUILDING_WALL			= 4;
	uint constant internal BUILDING_GATE			= 5;
	
	// 유닛
	uint constant internal UNIT_SWORDSMAN		= 4;
	uint constant internal UNIT_AXEMAN			= 2;
	uint constant internal UNIT_SPEARMAN		= 6;
	uint constant internal UNIT_SHIELDMAN		= 0;
	uint constant internal UNIT_SPY				= 11;
	uint constant internal UNIT_ARCHER			= 8;
	uint constant internal UNIT_CROSSBOWMAN		= 7;
	uint constant internal UNIT_BALLISTA		= 10;
	uint constant internal UNIT_CATAPULT		= 9;
	uint constant internal UNIT_CAVALY			= 5;
	uint constant internal UNIT_CAMELRY			= 3;
	uint constant internal UNIT_WAR_ELEPHANT	= 1;
	uint constant internal UNIT_KNIGHT			= 12;
	uint constant internal UNIT_KIND_COUNT		= 13;
	
	// 아이템
	uint constant internal ITEM_AXE			= 0;
	uint constant internal ITEM_SPEAR		= 1;
	uint constant internal ITEM_SHIELD		= 2;
	uint constant internal ITEM_HOOD		= 3;
	uint constant internal ITEM_CROSSBOW	= 4;
	uint constant internal ITEM_BALLISTA	= 5;
	uint constant internal ITEM_CATAPULT	= 6;
	uint constant internal ITEM_CAMEL		= 7;
	uint constant internal ITEM_ELEPHANT	= 8;
}