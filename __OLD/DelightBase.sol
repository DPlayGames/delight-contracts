pragma solidity ^0.5.9;

import "./DelightItem.sol";
import "./DelightKnightItem.sol";
import "./Standard/ERC20.sol";
import "./Util/NetworkChecker.sol";
import "./Util/SafeMath.sol";

contract DelightBase is NetworkChecker {
	using SafeMath for uint;
	
	// 지형의 범위
	uint constant internal COL_RANGE = 100;
	uint constant internal ROW_RANGE = 100;
	
	// 한 위치에 존재할 수 있는 최대 유닛 수
	uint constant internal MAX_POSITION_UNIT_COUNT = 50;
	
	// 올바른 범위인지 체크합니다.
	modifier checkRange(uint col, uint row) {
		require(col < COL_RANGE && row < ROW_RANGE);
		_;
	}
	
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
	
	// 기사의 기본 버프
	uint constant internal KNIGHT_DEFAULT_BUFF_HP = 10;
	uint constant internal KNIGHT_DEFAULT_BUFF_DAMAGE = 5;
	
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
		
		/**/
	}
}