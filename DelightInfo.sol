pragma solidity ^0.5.9;

import "./DelightInfoInterface.sol";
import "./DelightBase.sol";

contract DelightInfo is DelightInfoInterface, DelightBase {
	
	// Unit information
	// 유닛 정보
	mapping(uint => Unit) private units;
	
	// Material information
	// 재료 정보
	mapping(uint => Material) private buildingMaterials;
	mapping(uint => Material) private hpUpgradeMaterials;
	mapping(uint => Material) private unitMaterials;
	mapping(uint => Material) private itemMaterials;
	
	constructor() public {
		
		units[UNIT_SWORDSMAN] = Unit({
			hp : 100,
			damage : 50,
			movableDistance : 4,
			attackableDistance : 0
		});
		
		units[UNIT_AXEMAN] = Unit({
			hp : 150,
			damage : 50,
			movableDistance : 4,
			attackableDistance : 0
		});
		
		units[UNIT_SPEARMAN] = Unit({
			hp : 100,
			damage : 75,
			movableDistance : 4,
			attackableDistance : 0
		});
		
		units[UNIT_SHIELDMAN] = Unit({
			hp : 250,
			damage : 5,
			movableDistance : 4,
			attackableDistance : 0
		});
		
		units[UNIT_SPY] = Unit({
			hp : 50,
			damage : 50,
			movableDistance : 6,
			attackableDistance : 0
		});
		
		units[UNIT_ARCHER] = Unit({
			hp : 70,
			damage : 20,
			movableDistance : 4,
			attackableDistance : 2
		});
		
		units[UNIT_CROSSBOWMAN] = Unit({
			hp : 70,
			damage : 30,
			movableDistance : 4,
			attackableDistance : 2
		});
		
		units[UNIT_BALLISTA] = Unit({
			hp : 20,
			damage : 35,
			movableDistance : 0,
			attackableDistance : 4
		});
		
		units[UNIT_CATAPULT] = Unit({
			hp : 30,
			damage : 40,
			movableDistance : 2,
			attackableDistance : 3
		});
		
		units[UNIT_CAVALY] = Unit({
			hp : 150,
			damage : 50,
			movableDistance : 8,
			attackableDistance : 0
		});
		
		units[UNIT_CAMELRY] = Unit({
			hp : 300,
			damage : 50,
			movableDistance : 6,
			attackableDistance : 0
		});
		
		units[UNIT_WAR_ELEPHANT] = Unit({
			hp : 400,
			damage : 50,
			movableDistance : 4,
			attackableDistance : 0
		});
		
		units[UNIT_KNIGHT] = Unit({
			hp : 500,
			damage : 100,
			movableDistance : 4,
			attackableDistance : 0
		});
		
		buildingMaterials[BUILDING_HQ] = Material({
			wood : 400,
			stone : 0,
			iron : 0,
			ducat : 100
		});
		
		hpUpgradeMaterials[1] = Material({
			wood : 0,
			stone : 400,
			iron : 0,
			ducat : 200
		});
		
		hpUpgradeMaterials[2] = Material({
			wood : 0,
			stone : 0,
			iron : 400,
			ducat : 300
		});
		
		buildingMaterials[BUILDING_TRAINING_CENTER] = Material({
			wood : 300,
			stone : 50,
			iron : 100,
			ducat : 100
		});
		
		buildingMaterials[BUILDING_ARCHERY_RANGE] = Material({
			wood : 200,
			stone : 50,
			iron : 200,
			ducat : 200
		});
		
		buildingMaterials[BUILDING_STABLE] = Material({
			wood : 100,
			stone : 50,
			iron : 300,
			ducat : 300
		});
		
		buildingMaterials[BUILDING_TOWER] = Material({
			wood : 0,
			stone : 400,
			iron : 0,
			ducat : 0
		});
		
		unitMaterials[UNIT_KNIGHT] = Material({
			wood : 0,
			stone : 0,
			iron : 300,
			ducat : 1000
		});
		
		unitMaterials[UNIT_SWORDSMAN] = Material({
			wood : 0,
			stone : 0,
			iron : 200,
			ducat : 100
		});
		
		unitMaterials[UNIT_ARCHER] = Material({
			wood : 50,
			stone : 0,
			iron : 100,
			ducat : 100
		});
		
		unitMaterials[UNIT_CAVALY] = Material({
			wood : 100,
			stone : 0,
			iron : 200,
			ducat : 300
		});
		
		itemMaterials[ITEM_AXE] = Material({
			wood : 50,
			stone : 0,
			iron : 50,
			ducat : 0
		});
		
		itemMaterials[ITEM_SPEAR] = Material({
			wood : 75,
			stone : 0,
			iron : 25,
			ducat : 0
		});
		
		itemMaterials[ITEM_SHIELD] = Material({
			wood : 0,
			stone : 0,
			iron : 100,
			ducat : 0
		});
		
		itemMaterials[ITEM_HOOD] = Material({
			wood : 0,
			stone : 0,
			iron : 0,
			ducat : 100
		});
		
		itemMaterials[ITEM_CROSSBOW] = Material({
			wood : 100,
			stone : 0,
			iron : 50,
			ducat : 0
		});
		
		itemMaterials[ITEM_BALLISTA] = Material({
			wood : 200,
			stone : 0,
			iron : 100,
			ducat : 100
		});
		
		itemMaterials[ITEM_CATAPULT] = Material({
			wood : 200,
			stone : 200,
			iron : 0,
			ducat : 100
		});
		
		itemMaterials[ITEM_CAMEL] = Material({
			wood : 50,
			stone : 0,
			iron : 50,
			ducat : 200
		});
		
		itemMaterials[ITEM_ELEPHANT] = Material({
			wood : 100,
			stone : 0,
			iron : 100,
			ducat : 300
		});
		
		unitMaterials[UNIT_AXEMAN] = Material({
			wood	: unitMaterials[UNIT_SWORDSMAN].wood	+ itemMaterials[ITEM_AXE].wood,
			stone	: unitMaterials[UNIT_SWORDSMAN].stone	+ itemMaterials[ITEM_AXE].stone,
			iron	: unitMaterials[UNIT_SWORDSMAN].iron	+ itemMaterials[ITEM_AXE].iron,
			ducat	: unitMaterials[UNIT_SWORDSMAN].ducat	+ itemMaterials[ITEM_AXE].ducat
		});
		
		unitMaterials[UNIT_SPEARMAN] = Material({
			wood	: unitMaterials[UNIT_SWORDSMAN].wood	+ itemMaterials[ITEM_SPEAR].wood,
			stone	: unitMaterials[UNIT_SWORDSMAN].stone	+ itemMaterials[ITEM_SPEAR].stone,
			iron	: unitMaterials[UNIT_SWORDSMAN].iron	+ itemMaterials[ITEM_SPEAR].iron,
			ducat	: unitMaterials[UNIT_SWORDSMAN].ducat	+ itemMaterials[ITEM_SPEAR].ducat
		});
		
		unitMaterials[UNIT_SHIELDMAN] = Material({
			wood	: unitMaterials[UNIT_SWORDSMAN].wood	+ itemMaterials[ITEM_SHIELD].wood,
			stone	: unitMaterials[UNIT_SWORDSMAN].stone	+ itemMaterials[ITEM_SHIELD].stone,
			iron	: unitMaterials[UNIT_SWORDSMAN].iron	+ itemMaterials[ITEM_SHIELD].iron,
			ducat	: unitMaterials[UNIT_SWORDSMAN].ducat	+ itemMaterials[ITEM_SHIELD].ducat
		});
		
		unitMaterials[UNIT_SPY] = Material({
			wood	: unitMaterials[UNIT_SWORDSMAN].wood	+ itemMaterials[ITEM_HOOD].wood,
			stone	: unitMaterials[UNIT_SWORDSMAN].stone	+ itemMaterials[ITEM_HOOD].stone,
			iron	: unitMaterials[UNIT_SWORDSMAN].iron	+ itemMaterials[ITEM_HOOD].iron,
			ducat	: unitMaterials[UNIT_SWORDSMAN].ducat	+ itemMaterials[ITEM_HOOD].ducat
		});
		
		unitMaterials[UNIT_CROSSBOWMAN] = Material({
			wood	: unitMaterials[UNIT_ARCHER].wood	+ itemMaterials[ITEM_CROSSBOW].wood,
			stone	: unitMaterials[UNIT_ARCHER].stone	+ itemMaterials[ITEM_CROSSBOW].stone,
			iron	: unitMaterials[UNIT_ARCHER].iron	+ itemMaterials[ITEM_CROSSBOW].iron,
			ducat	: unitMaterials[UNIT_ARCHER].ducat	+ itemMaterials[ITEM_CROSSBOW].ducat
		});
		
		unitMaterials[UNIT_BALLISTA] = Material({
			wood	: unitMaterials[UNIT_ARCHER].wood	+ itemMaterials[ITEM_BALLISTA].wood,
			stone	: unitMaterials[UNIT_ARCHER].stone	+ itemMaterials[ITEM_BALLISTA].stone,
			iron	: unitMaterials[UNIT_ARCHER].iron	+ itemMaterials[ITEM_BALLISTA].iron,
			ducat	: unitMaterials[UNIT_ARCHER].ducat	+ itemMaterials[ITEM_BALLISTA].ducat
		});
		
		unitMaterials[UNIT_CATAPULT] = Material({
			wood	: unitMaterials[UNIT_ARCHER].wood	+ itemMaterials[ITEM_CATAPULT].wood,
			stone	: unitMaterials[UNIT_ARCHER].stone	+ itemMaterials[ITEM_CATAPULT].stone,
			iron	: unitMaterials[UNIT_ARCHER].iron	+ itemMaterials[ITEM_CATAPULT].iron,
			ducat	: unitMaterials[UNIT_ARCHER].ducat	+ itemMaterials[ITEM_CATAPULT].ducat
		});
		
		unitMaterials[UNIT_CAMELRY] = Material({
			wood	: unitMaterials[UNIT_CAVALY].wood	+ itemMaterials[ITEM_CAMEL].wood,
			stone	: unitMaterials[UNIT_CAVALY].stone	+ itemMaterials[ITEM_CAMEL].stone,
			iron	: unitMaterials[UNIT_CAVALY].iron	+ itemMaterials[ITEM_CAMEL].iron,
			ducat	: unitMaterials[UNIT_CAVALY].ducat	+ itemMaterials[ITEM_CAMEL].ducat
		});
		
		unitMaterials[UNIT_WAR_ELEPHANT] = Material({
			wood	: unitMaterials[UNIT_CAVALY].wood	+ itemMaterials[ITEM_ELEPHANT].wood,
			stone	: unitMaterials[UNIT_CAVALY].stone	+ itemMaterials[ITEM_ELEPHANT].stone,
			iron	: unitMaterials[UNIT_CAVALY].iron	+ itemMaterials[ITEM_ELEPHANT].iron,
			ducat	: unitMaterials[UNIT_CAVALY].ducat	+ itemMaterials[ITEM_ELEPHANT].ducat
		});
	}
	
	function getUnitHP					(uint kind) view external returns (uint) { return units[kind].hp; }
	function getUnitDamage				(uint kind) view external returns (uint) { return units[kind].damage; }
	function getUnitMovableDistance		(uint kind) view external returns (uint) { return units[kind].movableDistance; }
	function getUnitAttackableDistance	(uint kind) view external returns (uint) { return units[kind].attackableDistance; }
	
	function getBuildingMaterialWood	(uint kind) view external returns (uint) { return buildingMaterials[kind].wood; }
	function getBuildingMaterialStone	(uint kind) view external returns (uint) { return buildingMaterials[kind].stone; }
	function getBuildingMaterialIron	(uint kind) view external returns (uint) { return buildingMaterials[kind].iron; }
	function getBuildingMaterialDucat	(uint kind) view external returns (uint) { return buildingMaterials[kind].ducat; }
	
	function getHQUpgradeMaterialWood	(uint level) view external returns (uint) { return hpUpgradeMaterials[level].wood; }
	function getHQUpgradeMaterialStone	(uint level) view external returns (uint) { return hpUpgradeMaterials[level].stone; }
	function getHQUpgradeMaterialIron	(uint level) view external returns (uint) { return hpUpgradeMaterials[level].iron; }
	function getHQUpgradeMaterialDucat	(uint level) view external returns (uint) { return hpUpgradeMaterials[level].ducat; }
	
	function getUnitMaterialWood	(uint kind) view external returns (uint) { return unitMaterials[kind].wood; }
	function getUnitMaterialStone	(uint kind) view external returns (uint) { return unitMaterials[kind].stone; }
	function getUnitMaterialIron	(uint kind) view external returns (uint) { return unitMaterials[kind].iron; }
	function getUnitMaterialDucat	(uint kind) view external returns (uint) { return unitMaterials[kind].ducat; }
	
	function getItemMaterialWood	(uint kind) view external returns (uint) { return itemMaterials[kind].wood; }
	function getItemMaterialStone	(uint kind) view external returns (uint) { return itemMaterials[kind].stone; }
	function getItemMaterialIron	(uint kind) view external returns (uint) { return itemMaterials[kind].iron; }
	function getItemMaterialDucat	(uint kind) view external returns (uint) { return itemMaterials[kind].ducat; }
}
