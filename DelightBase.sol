pragma solidity ^0.5.9;

import "./DelightInterface.sol";
import "./Standard/ERC20.sol";
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
	uint constant private MAX_POSITION_UNIT_COUNT = 100;
	
	// 건물
	uint constant internal BUILDING_HQ = 0;
	uint constant internal BUILDING_TRAINING_CENTER = 1;
	uint constant internal BUILDING_ARCHERY_RANGE = 2;
	uint constant internal BUILDING_STABLE = 3;
	uint constant internal BUILDING_WALL = 4;
	uint constant internal BUILDING_GATE = 5;
	
	// 유닛
	uint constant internal ARMY_KNIGHT = 0;
	uint constant internal ARMY_SWORDSMAN = 1;
	uint constant internal ARMY_ARCHER = 2;
	uint constant internal ARMY_CAVALY = 3;
	
	// 아이템
	uint constant private ITEM_AXE = 0;
	uint constant private ITEM_SPEAR = 1;
	uint constant private ITEM_SHIELD = 2;
	uint constant private ITEM_HOOD = 3;
	uint constant private ITEM_CROSSBOW = 4;
	uint constant private ITEM_BALLISTA = 5;
	uint constant private ITEM_CATAPULT = 6;
	uint constant private ITEM_CAMEL = 7;
	uint constant private ITEM_ELEPHANT = 8;
	
	ERC20 internal wood;
	ERC20 internal stone;
	ERC20 internal iron;
	ERC20 internal ducat;
	
	Material[] internal buildingMaterials;
	Material[] internal unitMaterials;
	Material[] internal itemMaterials;
	
	Building[] internal buildings;
	Army[] internal armies;
	
	mapping(uint => mapping(uint => uint)) internal positionToBuildingId;
	mapping(uint => mapping(uint => uint[])) internal positionToArmyIds;
	
	mapping(uint => address) internal buildingIdToOwner;
	mapping(uint => address) internal armyIdToOwner;
	
	constructor() NetworkChecker() public {
		
		if (network == Network.Mainnet) {
			//TODO
		} else if (network == Network.Kovan) {
			//TODO
			wood = ERC20(0x0);
			stone = ERC20(0x0);
			iron = ERC20(0x0);
			ducat = ERC20(0x0);
		} else if (network == Network.Ropsten) {
			//TODO
		} else if (network == Network.Rinkeby) {
			//TODO
		} else {
			revert();
		}
		
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