pragma solidity ^0.5.9;

import "./DelightInterface.sol";
import "./DelightItem.sol";
import "./Standard/ERC20.sol";
import "./Standard/ERC721.sol";
import "./Util/NetworkChecker.sol";
import "./Util/SafeMath.sol";

contract DelightBase is DelightInterface, NetworkChecker {
	using SafeMath for uint;
	
	// 지형의 범위
	uint constant private COL_RANGE = 100;
	uint constant private ROW_RANGE = 100;
	
	// 범위를 체크합니다.
	modifier checkRange(uint col, uint row) {
		require(col < COL_RANGE && row < ROW_RANGE);
		_;
	}
	
	// 한 위치에 존재할 수 있는 최대 유닛 수
	uint constant internal MAX_POSITION_UNIT_COUNT = 50;
	
	// 건물
	uint constant internal BUILDING_HQ = 0;
	uint constant internal BUILDING_TRAINING_CENTER = 1;
	uint constant internal BUILDING_ARCHERY_RANGE = 2;
	uint constant internal BUILDING_STABLE = 3;
	uint constant internal BUILDING_WALL = 4;
	uint constant internal BUILDING_GATE = 5;
	
	// 유닛
	uint constant internal ARMY_SWORDSMAN = 0;
	uint constant internal ARMY_AXEMAN = 1;
	uint constant internal ARMY_SPEARMAN = 2;
	uint constant internal ARMY_SHIELDMAN = 3;
	uint constant internal ARMY_SPY = 4;
	uint constant internal ARMY_ARCHER = 5;
	uint constant internal ARMY_CROSSBOWMAN = 6;
	uint constant internal ARMY_BALLISTA = 7;
	uint constant internal ARMY_CATAPULT = 8;
	uint constant internal ARMY_CAVALY = 9;
	uint constant internal ARMY_CAMELRY = 10;
	uint constant internal ARMY_WAR_ELEPHANT = 11;
	uint constant internal ARMY_KNIGHT = 12;
	
	// 아이템
	uint constant internal ITEM_AXE = 0;
	uint constant internal ITEM_SPEAR = 1;
	uint constant internal ITEM_SHIELD = 2;
	uint constant internal ITEM_HOOD = 3;
	uint constant internal ITEM_CROSSBOW = 4;
	uint constant internal ITEM_BALLISTA = 5;
	uint constant internal ITEM_CATAPULT = 6;
	uint constant internal ITEM_CAMEL = 7;
	uint constant internal ITEM_ELEPHANT = 8;
	
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
	
	ERC721 internal knightItem;
	
	Material[] internal buildingMaterials;
	Material[] internal unitMaterials;
	Material[] internal itemMaterials;
	
	Building[] internal buildings;
	Army[] internal armies;
	
	// 공격 우선순위
	mapping(uint => uint) internal attackPriority;
	
	mapping(uint => mapping(uint => uint)) internal positionToBuildingId;
	mapping(uint => mapping(uint => uint[])) internal positionToArmyIds;
	
	mapping(address => uint[]) internal ownerToHQIds;
	
	mapping(uint => address) internal buildingIdToOwner;
	mapping(uint => address) internal armyIdToOwner;
	
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
			knightItem = ERC721(0x0);
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
		
		attackPriority[ARMY_SWORDSMAN] = 5;
		attackPriority[ARMY_AXEMAN] = 3;
		attackPriority[ARMY_SPEARMAN] = 7;
		attackPriority[ARMY_SHIELDMAN] = 1;
		attackPriority[ARMY_SPY] = 12;
		attackPriority[ARMY_ARCHER] = 9;
		attackPriority[ARMY_CROSSBOWMAN] = 8;
		attackPriority[ARMY_BALLISTA] = 11;
		attackPriority[ARMY_CATAPULT] = 10;
		attackPriority[ARMY_CAVALY] = 6;
		attackPriority[ARMY_CAMELRY] = 4;
		attackPriority[ARMY_WAR_ELEPHANT] = 2;
		attackPriority[ARMY_KNIGHT] = 13;
		
		// BUILDING_HQ
		buildingMaterials.push(Material({
			wood : 400,
			stone : 0,
			iron : 0,
			ducat : 100
		}));
		
		// BUILDING_TRAINING_CENTER
		buildingMaterials.push(Material({
			wood : 300,
			stone : 50,
			iron : 100,
			ducat : 100
		}));
		
		// BUILDING_ARCHERY_RANGE
		buildingMaterials.push(Material({
			wood : 200,
			stone : 50,
			iron : 200,
			ducat : 200
		}));
		
		// BUILDING_STABLE
		buildingMaterials.push(Material({
			wood : 100,
			stone : 50,
			iron : 300,
			ducat : 300
		}));
		
		// BUILDING_WALL
		buildingMaterials.push(Material({
			wood : 0,
			stone : 400,
			iron : 0,
			ducat : 0
		}));
		
		// BUILDING_GATE
		buildingMaterials.push(Material({
			wood : 100,
			stone : 600,
			iron : 200,
			ducat : 0
		}));
		
		// ARMY_KNIGHT
		unitMaterials.push(Material({
			wood : 0,
			stone : 0,
			iron : 300,
			ducat : 1000
		}));
		
		// ARMY_SWORDSMAN
		unitMaterials.push(Material({
			wood : 0,
			stone : 0,
			iron : 200,
			ducat : 100
		}));
		
		// ARMY_ARCHER
		unitMaterials.push(Material({
			wood : 50,
			stone : 0,
			iron : 100,
			ducat : 100
		}));
		
		// ARMY_CAVALY
		unitMaterials.push(Material({
			wood : 100,
			stone : 0,
			iron : 200,
			ducat : 300
		}));
		
		// ITEM_AXE
		itemMaterials.push(Material({
			wood : 50,
			stone : 0,
			iron : 50,
			ducat : 0
		}));
		
		// ITEM_SPEAR
		itemMaterials.push(Material({
			wood : 75,
			stone : 0,
			iron : 25,
			ducat : 0
		}));
		
		// ITEM_SHIELD
		itemMaterials.push(Material({
			wood : 0,
			stone : 0,
			iron : 100,
			ducat : 0
		}));
		
		// ITEM_HOOD
		itemMaterials.push(Material({
			wood : 0,
			stone : 0,
			iron : 0,
			ducat : 100
		}));
		
		// ITEM_CROSSBOW
		itemMaterials.push(Material({
			wood : 100,
			stone : 0,
			iron : 50,
			ducat : 0
		}));
		
		// ITEM_BALLISTA
		itemMaterials.push(Material({
			wood : 200,
			stone : 0,
			iron : 100,
			ducat : 100
		}));
		
		// ITEM_CATAPULT
		itemMaterials.push(Material({
			wood : 200,
			stone : 200,
			iron : 0,
			ducat : 100
		}));
		
		// ITEM_CAMEL
		itemMaterials.push(Material({
			wood : 50,
			stone : 0,
			iron : 50,
			ducat : 200
		}));
		
		// ITEM_ELEPHANT
		itemMaterials.push(Material({
			wood : 100,
			stone : 0,
			iron : 100,
			ducat : 300
		}));
	}
}