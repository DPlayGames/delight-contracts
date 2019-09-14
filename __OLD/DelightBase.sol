pragma solidity ^0.5.9;

import "./DelightInterface.sol";
import "./DelightItem.sol";
import "./DelightKnightItem.sol";
import "./Standard/ERC20.sol";
import "./Util/NetworkChecker.sol";
import "./Util/SafeMath.sol";

contract DelightBase is DelightInterface, NetworkChecker {
	using SafeMath for uint;
	
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
	
	Building[] internal buildings;
	Army[] internal armies;
	
	Record[] internal history;
	mapping(uint => RecordDetail[]) internal recordIdToDetails;
	
	mapping(uint => mapping(uint => uint)) internal positionToBuildingId;
	mapping(uint => mapping(uint => uint[])) internal positionToArmyIds;
	
	mapping(address => uint[]) internal ownerToHQIds;
	
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
			kind : 99,
			
			owner : address(0x0),
			enemy : address(0x0),
			
			col : 0,
			row : 0,
			toCol : 0,
			toRow : 0,
			
			buildingId : 0,
			buildingKind : 0,
			buildingLevel : 0,
			
			armyId : 0,
			unitKind : 0,
			unitCount : 0,
			
			itemId : 0,
			itemKind : 0,
			itemCount : 0,
			
			wood : 0,
			stone : 0,
			iron : 0,
			ducat : 0,
			
			enemyWood : 0,
			enemyStone : 0,
			enemyIron : 0,
			enemyDucat : 0,
			
			time : now
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