pragma solidity ^0.5.9;

import "./DelightBase.sol";

contract DelightInfo is DelightBase {
	
	// 유닛 정보
	struct Unit {
		uint hp;
		uint damage;
		uint movableDistance;
		uint attackableDistance;
	}
	
	// 재료 정보
	struct Material {
		uint wood;
		uint stone;
		uint iron;
		uint ducat;
	}
	
	// 유닛 정보
	mapping(uint => Unit) internal units;
	
	// 재료 정보
	mapping(uint => Material) internal buildingMaterials;
	mapping(uint => Material) internal hpUpgradeMaterials;
	mapping(uint => Material) internal unitMaterials;
	mapping(uint => Material) internal itemMaterials;
	
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
			movableDistance : 2,
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
		
		buildingMaterials[BUILDING_WALL] = Material({
			wood : 0,
			stone : 400,
			iron : 0,
			ducat : 0
		});
		
		buildingMaterials[BUILDING_GATE] = Material({
			wood : 100,
			stone : 600,
			iron : 200,
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