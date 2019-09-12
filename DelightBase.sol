pragma solidity ^0.5.9;

import "./DelightInterface.sol";
import "./DelightItem.sol";
import "./DelightKnightItem.sol";
import "./Standard/ERC20.sol";
import "./Util/NetworkChecker.sol";
import "./Util/SafeMath.sol";

contract DelightBase is DelightInterface, NetworkChecker {
	using SafeMath for uint;
	
	// 지형의 범위
	uint constant internal COL_RANGE = 100;
	uint constant internal ROW_RANGE = 100;
	
	// 한 위치에 존재할 수 있는 최대 유닛 수
	uint constant internal MAX_POSITION_UNIT_COUNT = 50;
	
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
	mapping(uint => Material) internal unitMaterials;
	mapping(uint => Material) internal itemMaterials;
	
	Building[] internal buildings;
	Army[] internal armies;
	
	Record[] internal history;
	
	mapping(uint => mapping(uint => uint)) internal positionToBuildingId;
	mapping(uint => mapping(uint => uint[])) internal positionToArmyIds;
	
	mapping(address => uint[]) internal ownerToHQIds;
	
	mapping(uint => address) internal buildingIdToOwner;
	mapping(uint => address) internal armyIdToOwner;
	
	// 특정 위치에 존재하는 부대의 소유주를 가져옵니다.
	function getArmyOwnerByPosition(uint col, uint row) view internal returns (address) {
		
		uint[] memory armyIds = positionToArmyIds[col][row];
		
		for (uint i = 0; i < armyIds.length; i += 1) {
			
			address owner = armies[armyIds[i]].owner;
			if (owner != address(0x0)) {
				return owner;
			}
		}
		
		return address(0x0);
	}
	
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
		
		// 0번지는 사용하지 않습니다.
		buildings.push(Building({
			kind : 99,
			level : 0,
			col : COL_RANGE,
			row : ROW_RANGE,
			owner : msg.sender,
			buildTime : now
		}));
		
		// 0번지는 사용하지 않습니다.
		armies.push(Army({
			unitKind : 99,
			unitCount : 0,
			knightItemId : 0,
			col : COL_RANGE,
			row : ROW_RANGE,
			owner : msg.sender,
			createTime : now
		}));
		
		// 0번지는 사용하지 않습니다.
		history.push(Record({
			kind : 99
		}));
		
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