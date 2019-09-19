pragma solidity ^0.5.9;

interface DelightInfoInterface {
	
	// Unit information
	// 유닛 정보
	struct Unit {
		uint hp;
		uint damage;
		uint movableDistance;
		uint attackableDistance;
	}
	
	// Material information
	// 재료 정보
	struct Material {
		uint wood;
		uint stone;
		uint iron;
		uint ducat;
	}
	
	function getUnitHP					(uint kind) view external returns (uint);
	function getUnitDamage				(uint kind) view external returns (uint);
	function getUnitMovableDistance		(uint kind) view external returns (uint);
	function getUnitAttackableDistance	(uint kind) view external returns (uint);
	
	function getBuildingMaterialWood	(uint kind) view external returns (uint);
	function getBuildingMaterialStone	(uint kind) view external returns (uint);
	function getBuildingMaterialIron	(uint kind) view external returns (uint);
	function getBuildingMaterialDucat	(uint kind) view external returns (uint);
	
	function getHQUpgradeMaterialWood	(uint level) view external returns (uint);
	function getHQUpgradeMaterialStone	(uint level) view external returns (uint);
	function getHQUpgradeMaterialIron	(uint level) view external returns (uint);
	function getHQUpgradeMaterialDucat	(uint level) view external returns (uint);
	
	function getUnitMaterialWood	(uint kind) view external returns (uint);
	function getUnitMaterialStone	(uint kind) view external returns (uint);
	function getUnitMaterialIron	(uint kind) view external returns (uint);
	function getUnitMaterialDucat	(uint kind) view external returns (uint);
	
	function getItemMaterialWood	(uint kind) view external returns (uint);
	function getItemMaterialStone	(uint kind) view external returns (uint);
	function getItemMaterialIron	(uint kind) view external returns (uint);
	function getItemMaterialDucat	(uint kind) view external returns (uint);
}
