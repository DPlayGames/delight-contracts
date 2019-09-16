pragma solidity ^0.5.9;

import "./DelightBuildingManagerInterface.sol";
import "./DelightManager.sol";
import "./DelightArmyManager.sol";
import "./DelightItemManager.sol";
import "./Util/SafeMath.sol";

contract DelightBuildingManager is DelightBuildingManagerInterface, DelightManager {
	using SafeMath for uint;
	
	// Delight 부대 관리자
	DelightArmyManager public delightArmyManager;
	
	// Delight 아이템 관리자
	DelightItemManager public delightItemManager;
	
	function setDelightArmyManagerOnce(address addr) external {
		
		// 비어있는 주소인 경우에만
		require(address(delightArmyManager) == address(0));
		
		delightArmyManager = DelightArmyManager(addr);
	}
	
	function setDelightItemManagerOnce(address addr) external {
		
		// 비어있는 주소인 경우에만
		require(address(delightItemManager) == address(0));
		
		delightItemManager = DelightItemManager(addr);
	}
	
	// Sender가 Delight일때만 실행
	modifier onlyDelight() {
		require(
			msg.sender == delight ||
			msg.sender == address(delightArmyManager) ||
			msg.sender == address(delightItemManager)
		);
		_;
	}
	
	Building[] private buildings;
	
	mapping(uint => mapping(uint => uint)) private positionToBuildingId;
	mapping(address => uint[]) private ownerToHQIds;
	
	// 건물의 총 개수를 반환합니다.
	function getBuildingCount() view external returns (uint) {
		return buildings.length;
	}
	
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
	
	// 특정 위치의 건물 ID를 반환합니다.
	function getPositionBuildingId(uint col, uint row) view external returns (uint) {
		return positionToBuildingId[col][row];
	}
	
	// 특정 위치의 건물의 주인을 반환합니다.
	function getPositionBuildingOwner(uint col, uint row) view external returns (address) {
		return buildings[positionToBuildingId[col][row]].owner;
	}
	
	// 건물을 짓습니다.
	function build(address owner, uint kind, uint col, uint row) onlyDelight external {
		
		require(col < COL_RANGE && row < ROW_RANGE);
		
		// 필드에 건물이 존재하면 안됩니다.
		require(positionToBuildingId[col][row] == 0);
		
		address positionOwner = delightArmyManager.getPositionOwner(col, row);
		
		// 필드에 적군이 존재하면 안됩니다.
		require(positionOwner == address(0) || positionOwner == owner);
		
		// 본부가 주변에 존재하는지 확인합니다.
		bool existsHQAround = false;
		for (uint i = 0; i < ownerToHQIds[owner].length; i += 1) {
			
			Building memory building = buildings[ownerToHQIds[owner][i]];
			uint hqCol = building.col;
			uint hqRow = building.row;
			
			if (
			(col < hqCol ? hqCol - col : col - hqCol) +
			(row < hqRow ? hqRow - row : row - hqRow) <= 5 + building.level.mul(2)
			) {
				existsHQAround = true;
				break;
			}
		}
		
		require(
			
			// 월드에 본부가 아예 없거나, 본부가 주변에 존재하는지 확인합니다.
			ownerToHQIds[owner].length == 0 || existsHQAround == true ||
			
			// 본부인 경우, 내 병사가 있는 위치에 지을 수 있습니다.
			(kind == BUILDING_HQ && positionOwner == owner)
		);
		
		// 만약 월드에 본부가 아예 없는 경우, 처음 짓는 곳 주변에 건물이 존재하면 안됩니다.
		if (ownerToHQIds[owner].length == 0) {
			for (uint i = (col <= 9 ? 0 : col - 9); i < (col >= 91 ? 100 : col + 9); i += 1) {
				for (uint j = (row <= 9 ? 0 : row - 9); j < (row >= 91 ? 100 : row + 9); j += 1) {
					require(positionToBuildingId[i][j] == 0);
				}
			}
		}
		
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
		
		// 자원을 Delight로 이전합니다.
		wood.transferFrom(owner, delight, info.getBuildingMaterialWood(kind));
		stone.transferFrom(owner, delight, info.getBuildingMaterialStone(kind));
		iron.transferFrom(owner, delight, info.getBuildingMaterialIron(kind));
		ducat.transferFrom(owner, delight, info.getBuildingMaterialDucat(kind));
	}
	
	// 본부를 업그레이드합니다.
	function upgradeHQ(address owner, uint buildingId) onlyDelight external {
		
		Building storage building = buildings[buildingId];
		
		require(building.kind == BUILDING_HQ);
		
		// 건물 소유주만 업그레이드가 가능합니다.
		require(building.owner == owner);
		
		// 최대 레벨은 2입니다. (0 ~ 2)
		require(building.level < 2);
		
		uint toLevel = building.level + 1;
		
		// 본부를 업그레이드하는데 필요한 자원이 충분한지 확인합니다.
		require(
			wood.balanceOf(owner) >= info.getHQUpgradeMaterialWood(toLevel) &&
			stone.balanceOf(owner) >= info.getHQUpgradeMaterialStone(toLevel) &&
			iron.balanceOf(owner) >= info.getHQUpgradeMaterialIron(toLevel) &&
			ducat.balanceOf(owner) >= info.getHQUpgradeMaterialDucat(toLevel)
		);
		
		// 자원을 Delight로 이전합니다.
		wood.transferFrom(owner, delight, info.getHQUpgradeMaterialWood(toLevel));
		stone.transferFrom(owner, delight, info.getHQUpgradeMaterialStone(toLevel));
		iron.transferFrom(owner, delight, info.getHQUpgradeMaterialIron(toLevel));
		ducat.transferFrom(owner, delight, info.getHQUpgradeMaterialDucat(toLevel));
		
		building.level = toLevel;
	}
	
	// 건물에서 부대를 생산합니다.
	function createArmy(address owner, uint buildingId, uint unitCount) onlyDelight external {
		
		Building memory building = buildings[buildingId];
		
		// 건물 소유주만 부대 생산이 가능합니다.
		require(building.owner == owner);
		
		uint unitKind;
		
		// 본부의 경우 기사를 생산합니다.
		if (building.kind == BUILDING_HQ) {
			unitKind = UNIT_KNIGHT;
		}
		
		// 훈련소의 경우 검병을 생산합니다.
		else if (building.kind == BUILDING_TRAINING_CENTER) {
			unitKind = UNIT_SWORDSMAN;
		}
		
		// 사격소의 경우 궁수를 생산합니다.
		else if (building.kind == BUILDING_TRAINING_CENTER) {
			unitKind = UNIT_ARCHER;
		}
		
		// 마굿간의 경우 기마병을 생산합니다.
		else if (building.kind == BUILDING_STABLE) {
			unitKind = UNIT_CAVALY;
		}
		
		else {
			revert();
		}
		
		// 부대를 생산합니다.
		delightArmyManager.createArmy(owner, building.col, building.row, unitKind, unitCount);
	}
	
	// 특정 위치의 건물을 파괴합니다.
	function destroyBuilding(uint col, uint row) onlyDelight external returns (
		uint wood,
		uint stone,
		uint iron,
		uint ducat
	) {
		
		uint buildingId = positionToBuildingId[col][row];
		
		// 존재하는 건물이어야 합니다.
		require(buildingId != 0);
		
		Building memory building = buildings[buildingId];
		
		uint buildingKind = building.kind;
		
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
			
			// 본부 업그레이드 비용을 반환합니다.
			for (uint i = 1; i <= building.level; i += 1) {
				
				// 반환할 재료를 추가합니다.
				wood = wood.add(info.getHQUpgradeMaterialWood(buildingKind));
				stone = stone.add(info.getHQUpgradeMaterialStone(buildingKind));
				iron = iron.add(info.getHQUpgradeMaterialIron(buildingKind));
				ducat = ducat.add(info.getHQUpgradeMaterialDucat(buildingKind));
			}
		}
		
		// 반환할 재료를 추가합니다.
		wood = wood.add(info.getBuildingMaterialWood(buildingKind));
		stone = stone.add(info.getBuildingMaterialStone(buildingKind));
		iron = iron.add(info.getBuildingMaterialIron(buildingKind));
		ducat = ducat.add(info.getBuildingMaterialDucat(buildingKind));
		
		// 건물을 파괴합니다.
		delete buildings[buildingId];
		delete positionToBuildingId[col][row];
	}
}