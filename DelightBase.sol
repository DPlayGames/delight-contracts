pragma solidity ^0.5.9;

import "./DelightItem.sol";
import "./DelightKnightItem.sol";
import "./Standard/ERC20.sol";
import "./Util/NetworkChecker.sol";
import "./Util/SafeMath.sol";

contract DelightBase is NetworkChecker {
	using SafeMath for uint;
	
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
	
	// 건물 정보
	struct Building {
		uint kind;
		uint level;
		uint col;
		uint row;
		address owner;
		uint buildTime;
	}
	
	// 유닛 정보
	struct Unit {
		uint hp;
		uint damage;
		uint movableDistance;
		uint attackableDistance;
	}
	
	// 부대 정보
	struct Army {
		uint unitKind;
		uint unitCount;
		uint knightItemId;
		uint col;
		uint row;
		address owner;
		uint createTime;
	}
	
	// 재료 정보
	struct Material {
		uint wood;
		uint stone;
		uint iron;
		uint ducat;
	}
	
	ERC20 internal wood;
	ERC20 internal stone;
	ERC20 internal iron;
	ERC20 internal ducat;
	
	DelightItem internal axe;
	DelightItem internal spear;
	DelightItem internal shield;
	DelightItem internal hood;
	DelightItem internal crossbow;
	DelightItem internal ballista;
	DelightItem internal catapult;
	DelightItem internal camel;
	DelightItem internal elephant;
	
	function getItemContract(uint kind) view internal returns (DelightItem) {
		if (kind == ITEM_AXE) {
			return axe;
		} else if (kind == ITEM_SPEAR) {
			return spear;
		} else if (kind == ITEM_SHIELD) {
			return shield;
		} else if (kind == ITEM_HOOD) {
			return hood;
		} else if (kind == ITEM_CROSSBOW) {
			return crossbow;
		} else if (kind == ITEM_BALLISTA) {
			return ballista;
		} else if (kind == ITEM_CATAPULT) {
			return catapult;
		} else if (kind == ITEM_CAMEL) {
			return camel;
		} else if (kind == ITEM_ELEPHANT) {
			return elephant;
		}
	}
	
	DelightKnightItem internal knightItem;
	
	// 유닛 정보
	mapping(uint => Unit) internal units;
	
	// 재료 정보
	mapping(uint => Material) internal buildingMaterials;
	mapping(uint => Material) internal hpUpgradeMaterials;
	mapping(uint => Material) internal unitMaterials;
	mapping(uint => Material) internal itemMaterials;
	
	constructor() NetworkChecker() public {
		
		if (network == Network.Mainnet) {
			//TODO
		}
		
		else if (network == Network.Kovan) {
			//TODO
			
			// 자원들
			wood = ERC20(0x0);
			stone = ERC20(0x0);
			iron = ERC20(0x0);
			ducat = ERC20(0x0);
			
			// 아이템들
			axe = DelightItem(0x0);
			ballista = DelightItem(0x0);
			camel = DelightItem(0x0);
			catapult = DelightItem(0x0);
			crossbow = DelightItem(0x0);
			elephant = DelightItem(0x0);
			hood = DelightItem(0x0);
			shield = DelightItem(0x0);
			spear = DelightItem(0x0);
			
			// 기사 아이템
			knightItem = DelightKnightItem(0x0);
		}
		
		else if (network == Network.Ropsten) {
			//TODO
		}
		
		else if (network == Network.Rinkeby) {
			//TODO
		}
		
		else {
			revert();
		}
		
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
}