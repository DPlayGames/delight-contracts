pragma solidity ^0.5.9;

import "./DelightBuildingManagerInterface.sol";
import "./DelightManager.sol";
import "./DelightArmyManager.sol";
import "./DelightItemManager.sol";
import "./Util/SafeMath.sol";

contract DelightBuildingManager is DelightBuildingManagerInterface, DelightManager {
	using SafeMath for uint;
	
	// Delight army manager
	// Delight 부대 관리자
	DelightArmyManager private armyManager;
	
	// Delight item manager
	// Delight 아이템 관리자
	DelightItemManager private itemManager;
	
	function setDelightArmyManagerOnce(address addr) external {
		
		// The address has to be empty.
		// 비어있는 주소인 경우에만
		require(address(armyManager) == address(0));
		
		armyManager = DelightArmyManager(addr);
	}
	
	function setDelightItemManagerOnce(address addr) external {
		
		// The address has to be empty.
		// 비어있는 주소인 경우에만
		require(address(itemManager) == address(0));
		
		itemManager = DelightItemManager(addr);
	}
	
	// Executes only if the sender is Delight.
	// Sender가 Delight일때만 실행
	modifier onlyDelight() {
		require(
			msg.sender == delight ||
			msg.sender == address(armyManager) ||
			msg.sender == address(itemManager)
		);
		_;
	}
	
	Building[] private buildings;
	
	constructor() DelightManager() public {
		
		// Address 0 is not used.
		// 0번지는 사용하지 않습니다.
		buildings.push(Building({
			kind : 99,
			level : 0,
			col : COL_RANGE,
			row : ROW_RANGE,
			owner : address(0),
			buildTime : 0
		}));
	}
	
	mapping(uint => mapping(uint => uint)) private positionToBuildingId;
	mapping(address => uint[]) private ownerToHQIds;
	
	// Returns the total number of buildings.
	// 건물의 총 개수를 반환합니다.
	function getBuildingCount() view external returns (uint) {
		return buildings.length;
	}
	
	// Returns the information of a building.
	// 건물의 정보를 반환합니다.
	function getBuildingInfo(uint buildingId) view external returns (
		uint kind,
		uint level,
		uint col,
		uint row,
		address owner,
		uint buildTime
	) {
		Building memory building = buildings[buildingId];
		
		return (
			building.kind,
			building.level,
			building.col,
			building.row,
			building.owner,
			building.buildTime
		);
	}
	
	// Returns the IDs of the buildings located on a specific tile.
	// 특정 위치의 건물 ID를 반환합니다.
	function getPositionBuildingId(uint col, uint row) view external returns (uint) {
		return positionToBuildingId[col][row];
	}
	
	// Returns the owners of the buildings located on a specific tile.
	// 특정 위치의 건물의 주인을 반환합니다.
	function getPositionBuildingOwner(uint col, uint row) view external returns (address) {
		return buildings[positionToBuildingId[col][row]].owner;
	}
	
	// 특정 위치의 건물의 버프 HP를 반환합니다.
	function getBuildingBuffHP(uint col, uint row) view external returns (uint) {
		
		uint buildingId = positionToBuildingId[col][row];
		if (buildingId != 0) {
			
			// 탑인 경우 버프 HP는 20
			if (buildings[buildingId].kind == BUILDING_TOWER) {
				return 20;
			}
		}
		
		return 0;
	}
	
	// 특정 위치의 건물의 버프 데미지를 반환합니다.
	function getBuildingBuffDamage(uint col, uint row) view external returns (uint) {
		
		uint buildingId = positionToBuildingId[col][row];
		if (buildingId != 0) {
			
			// 탑인 경우 버프 데미지는 20
			if (buildings[buildingId].kind == BUILDING_TOWER) {
				return 20;
			}
		}
		
		return 0;
	}
	
	// Builds a building.
	// 건물을 짓습니다.
	function build(address owner, uint kind, uint col, uint row) onlyDelight external {
		
		// Checks the dimension.
		// 범위를 체크합니다.
		require(col < COL_RANGE && row < ROW_RANGE);
		
		// There should be no building on the construction site.
		// 필드에 건물이 존재하면 안됩니다.
		require(positionToBuildingId[col][row] == 0);
		
		address positionOwner = armyManager.getPositionOwner(col, row);
		
		// There should be no enemy on the construction site.
		// 필드에 적군이 존재하면 안됩니다.
		require(positionOwner == address(0) || positionOwner == owner);
		
		// Checks if a headquarter is near the construction site.
		// 본부가 주변에 존재하는지 확인합니다.
		bool existsHQAround = false;
		for (uint i = 0; i < ownerToHQIds[owner].length; i += 1) {
			
			Building memory building = buildings[ownerToHQIds[owner][i]];
			uint hqCol = building.col;
			uint hqRow = building.row;
			
			if (
			(col < hqCol ? hqCol - col : col - hqCol) +
			(row < hqRow ? hqRow - row : row - hqRow) <= 3 + building.level
			) {
				existsHQAround = true;
				break;
			}
		}
		
		require(
			// Checks if a headquarter is near the construction site.
			// 본부가 주변에 존재하는지 확인합니다.
			existsHQAround == true ||
			
			// An HQ can be built even when there's no other HQ in the world, or where the builder's units are.
			// 본부인 경우, 월드에 본부가 아예 없거나, 내 병사가 있는 위치에 지을 수 있습니다.
			(kind == BUILDING_HQ && (ownerToHQIds[owner].length == 0 || positionOwner == owner))
		);
		
		// If there's no other HQ of the builder in the world, there should be no any building near the construction site.
		// 만약 월드에 본부가 아예 없는 경우, 처음 짓는 곳 주변에 건물이 존재하면 안됩니다.
		if (ownerToHQIds[owner].length == 0) {
			for (uint i = (col <= 3 ? 0 : col - 3); i < (col >= 97 ? 100 : col + 3); i += 1) {
				for (uint j = (row <= 3 ? 0 : row - 3); j < (row >= 97 ? 100 : row + 3); j += 1) {
					require(positionToBuildingId[i][j] == 0);
				}
			}
		}
		
		// Checks if there are enough resources to build the building.
		// 건물을 짓는데 필요한 자원이 충분한지 확인합니다.
		require(
			wood.balanceOf(owner) >= info.getBuildingMaterialWood(kind) &&
			stone.balanceOf(owner) >= info.getBuildingMaterialStone(kind) &&
			iron.balanceOf(owner) >= info.getBuildingMaterialIron(kind) &&
			ducat.balanceOf(owner) >= info.getBuildingMaterialDucat(kind)
		);
		
		uint buildingId = buildings.push(Building({
			kind : kind,
			level : 0,
			col : col,
			row : row,
			owner : owner,
			buildTime : now
		})).sub(1);
		
		positionToBuildingId[col][row] = buildingId;
		
		if (kind == BUILDING_HQ) {
			ownerToHQIds[owner].push(buildingId);
		}
		
		// Transfers the resources to Delight.
		// 자원을 Delight로 이전합니다.
		wood.transferFrom(owner, delight, info.getBuildingMaterialWood(kind));
		stone.transferFrom(owner, delight, info.getBuildingMaterialStone(kind));
		iron.transferFrom(owner, delight, info.getBuildingMaterialIron(kind));
		ducat.transferFrom(owner, delight, info.getBuildingMaterialDucat(kind));
		
		// Emits the event.
		// 이벤트 발생
		emit Build(buildingId);
	}
	
	// Upgrades an HQ.
	// 본부를 업그레이드합니다.
	function upgradeHQ(address owner, uint buildingId) onlyDelight external {
		
		Building storage building = buildings[buildingId];
		
		require(building.kind == BUILDING_HQ);
		
		// Only the owner of the HQ can upgrade it.
		// 건물 소유주만 업그레이드가 가능합니다.
		require(building.owner == owner);
		
		// The maximum level is 2.
		// 최대 레벨은 2입니다. (0 ~ 2)
		require(building.level < 2);
		
		uint toLevel = building.level + 1;
		
		// Checks if there are enough resources to upgrade the HQ.
		// 본부를 업그레이드하는데 필요한 자원이 충분한지 확인합니다.
		require(
			wood.balanceOf(owner) >= info.getHQUpgradeMaterialWood(toLevel) &&
			stone.balanceOf(owner) >= info.getHQUpgradeMaterialStone(toLevel) &&
			iron.balanceOf(owner) >= info.getHQUpgradeMaterialIron(toLevel) &&
			ducat.balanceOf(owner) >= info.getHQUpgradeMaterialDucat(toLevel)
		);
		
		// Transfers resources to Delight.
		// 자원을 Delight로 이전합니다.
		wood.transferFrom(owner, delight, info.getHQUpgradeMaterialWood(toLevel));
		stone.transferFrom(owner, delight, info.getHQUpgradeMaterialStone(toLevel));
		iron.transferFrom(owner, delight, info.getHQUpgradeMaterialIron(toLevel));
		ducat.transferFrom(owner, delight, info.getHQUpgradeMaterialDucat(toLevel));
		
		building.level = toLevel;
		
		// Emits the event.
		// 이벤트 발생
		emit UpgradeHQ(buildingId);
	}
	
	// Creates an army from the building.
	// 건물에서 부대를 생산합니다.
	function createArmy(address owner, uint buildingId, uint unitCount) onlyDelight external {
		
		Building memory building = buildings[buildingId];
		
		// Only the owner of the building can create an army from it.
		// 건물 소유주만 부대 생산이 가능합니다.
		require(building.owner == owner);
		
		uint unitKind;
		
		// A hq creates knights.
		// 본부의 경우 기사를 생산합니다.
		if (building.kind == BUILDING_HQ) {
			unitKind = UNIT_KNIGHT;
		}
		
		// A training center creates swordsmen.
		// 훈련소의 경우 검병을 생산합니다.
		else if (building.kind == BUILDING_TRAINING_CENTER) {
			unitKind = UNIT_SWORDSMAN;
		}
		
		// An achery range creates archers.
		// 사격소의 경우 궁수를 생산합니다.
		else if (building.kind == BUILDING_ARCHERY_RANGE) {
			unitKind = UNIT_ARCHER;
		}
		
		// A stable creates cavalry.
		// 마굿간의 경우 기마병을 생산합니다.
		else if (building.kind == BUILDING_STABLE) {
			unitKind = UNIT_CAVALY;
		}
		
		else {
			revert();
		}
		
		// Creates the army.
		// 부대를 생산합니다.
		armyManager.createArmy(owner, building.col, building.row, unitKind, unitCount);
	}
	
	// Destory the building on a specific tile.
	// 특정 위치의 건물을 파괴합니다.
	function destroyBuilding(uint col, uint row) onlyDelight external returns (
		uint wood,
		uint stone,
		uint iron,
		uint ducat
	) {
		
		uint buildingId = positionToBuildingId[col][row];
		
		// The building must exist.
		// 존재하는 건물이어야 합니다.
		if (buildingId != 0) {
			
			Building memory building = buildings[buildingId];
			
			uint buildingKind = building.kind;
			
			// If it's an HQ, it is removed from the HQ list.
			// 본부인 경우, 본부 목록에서 제거합니다.
			if (buildingKind == BUILDING_HQ) {
				
				uint[] storage hqIds = ownerToHQIds[building.owner];
				
				for (uint i = hqIds.length - 1; i > 0; i -= 1) {
					
					if (hqIds[i - 1] == buildingId) {
						hqIds[i - 1] = hqIds[i];
						break;
					} else {
						hqIds[i - 1] = hqIds[i];
					}
				}
				
				hqIds.length -= 1;
				
				// Returns the upgrade cost of the HQ.
				// 본부 업그레이드 비용을 반환합니다.
				for (uint i = 1; i <= building.level; i += 1) {
					
					// Adds the returned material.
					// 반환할 재료를 추가합니다.
					wood = wood.add(info.getHQUpgradeMaterialWood(buildingKind));
					stone = stone.add(info.getHQUpgradeMaterialStone(buildingKind));
					iron = iron.add(info.getHQUpgradeMaterialIron(buildingKind));
					ducat = ducat.add(info.getHQUpgradeMaterialDucat(buildingKind));
				}
			}
			
			// Adds the returned material.
			// 반환할 재료를 추가합니다.
			wood = wood.add(info.getBuildingMaterialWood(buildingKind));
			stone = stone.add(info.getBuildingMaterialStone(buildingKind));
			iron = iron.add(info.getBuildingMaterialIron(buildingKind));
			ducat = ducat.add(info.getBuildingMaterialDucat(buildingKind));
			
			// Destroys the building.
			// 건물을 파괴합니다.
			delete buildings[buildingId];
			delete positionToBuildingId[col][row];
			
			// Emits the event.
			// 이벤트 발생
			emit DestroyBuilding(buildingId);
		}
	}
}
