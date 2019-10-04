pragma solidity ^0.5.9;

contract DelightBase {
	
	// Dimension of the world.
	// 지형의 범위
	uint constant internal COL_RANGE = 100;
	uint constant internal ROW_RANGE = 100;
	
	// Buildings
	// 건물
	uint constant internal BUILDING_HQ				= 1;
	uint constant internal BUILDING_TRAINING_CENTER	= 2;
	uint constant internal BUILDING_ARCHERY_RANGE	= 3;
	uint constant internal BUILDING_STABLE			= 4;
	uint constant internal BUILDING_TOWER			= 5;
	
	// Units
	// 유닛
	uint constant internal UNIT_SWORDSMAN		= 5;
	uint constant internal UNIT_AXEMAN			= 3;
	uint constant internal UNIT_SPEARMAN		= 7;
	uint constant internal UNIT_SHIELDMAN		= 1;
	uint constant internal UNIT_SPY				= 12;
	uint constant internal UNIT_ARCHER			= 8;
	uint constant internal UNIT_CROSSBOWMAN		= 8;
	uint constant internal UNIT_BALLISTA		= 11;
	uint constant internal UNIT_CATAPULT		= 10;
	uint constant internal UNIT_CAVALY			= 6;
	uint constant internal UNIT_CAMELRY			= 4;
	uint constant internal UNIT_WAR_ELEPHANT	= 2;
	uint constant internal UNIT_KNIGHT			= 13;
	uint constant internal UNIT_KIND_COUNT		= 14;
	
	// Items
	// 아이템
	uint constant internal ITEM_AXE			= 1;
	uint constant internal ITEM_SPEAR		= 2;
	uint constant internal ITEM_SHIELD		= 3;
	uint constant internal ITEM_HOOD		= 4;
	uint constant internal ITEM_CROSSBOW	= 5;
	uint constant internal ITEM_BALLISTA	= 6;
	uint constant internal ITEM_CATAPULT	= 7;
	uint constant internal ITEM_CAMEL		= 8;
	uint constant internal ITEM_ELEPHANT	= 9;
}
