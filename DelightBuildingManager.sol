pragma solidity ^0.5.9;

import "./DelightBase.sol";
import "./Util/SafeMath.sol";

contract DelightBuildingManager is DelightBase {
	using SafeMath for uint;
	
	// 건물을 짓는 위치를 확인합니다.
	modifier checkBuildingPosition(uint col, uint row) {
		
		// 필드에 건물이 존재하면 안됩니다.
		require(positionToBuildingId[col][row] == 0);
		
		// 필드에 적군이 존재하면 안됩니다.
		require(positionToArmyIds[col][row].length == 0 || armyIdToOwner[positionToArmyIds[col][row][0]] == msg.sender);
		
		// 본부가 주변에 존재하는지 확인합니다.
		bool existsHQAround = false;
		for (uint i = 0; i < ownerToHQIds[msg.sender].length; i += 1) {
			
			Building memory building = buildings[ownerToHQIds[msg.sender][i]];
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
		
		// 월드에 본부가 아예 없거나, 본부가 주변에 존재하는지 확인합니다.
		require(ownerToHQIds[msg.sender].length == 0 || existsHQAround == true);
		_;
	}
	
	// 건물을 짓습니다.
	function build(uint kind, uint col, uint row)
	checkRange(col, row)
	checkBuildingPosition(col, row)
	internal returns (uint) {
		
		Material memory material = buildingMaterials[kind];
		
		// 건물을 짓는데 필요한 자원이 충분한지 확인합니다.
		require(
			wood.balanceOf(msg.sender) >= material.wood &&
			stone.balanceOf(msg.sender) >= material.stone &&
			iron.balanceOf(msg.sender) >= material.iron &&
			ducat.balanceOf(msg.sender) >= material.ducat
		);
		
		uint buildingId = buildings.push(Building({
			kind : kind,
			level : 0,
			col : col,
			row : row,
			owner : msg.sender,
			buildTime : now
		})).sub(1);
		
		positionToBuildingId[col][row] = buildingId;
		
		if (kind == BUILDING_HQ) {
			ownerToHQIds[msg.sender].push(buildingId);
		}
		
		// 자원을 Delight로 이전합니다.
		wood.transferFrom(msg.sender, address(this), material.wood);
		stone.transferFrom(msg.sender, address(this), material.stone);
		iron.transferFrom(msg.sender, address(this), material.iron);
		ducat.transferFrom(msg.sender, address(this), material.ducat);
		
		return buildingId;
	}
	
	// 본부를 업그레이드합니다.
	function upgradeHQ(uint buildingId) internal {
		
		Building storage building = buildings[buildingId];
		
		require(building.kind == BUILDING_HQ);
		require(building.level < 2);
		
		building.level += 1;
	}
	
	// 건물에서 부대를 생산합니다.
	function createArmy(uint buildingId, uint unitCount) internal returns (uint) {
		
		Building memory building = buildings[buildingId];
		
		// 건물 소유주만 부대 생산이 가능합니다.
		require(building.owner == msg.sender);
		
		// 건물이 위치한 곳의 총 유닛 숫자를 계산합니다.
		uint[] memory armyIds = positionToArmyIds[building.col][building.row];
		
		uint totalUnitCount = unitCount;
		for (uint i = 0; i < armyIds.length; i += 1) {
			totalUnitCount = totalUnitCount.add(armies[armyIds[i]].unitCount);
		}
		
		// 건물이 위치한 곳의 총 유닛 숫자가 최대 유닛 수를 넘기면 안됩니다.
		require(totalUnitCount <= MAX_POSITION_UNIT_COUNT);
		
		uint armyKind;
		
		// 본부의 경우 기사를 생산합니다.
		if (building.kind == BUILDING_HQ) {
			armyKind = ARMY_KNIGHT;
		}
		
		// 훈련소의 경우 검병을 생산합니다.
		else if (building.kind == BUILDING_TRAINING_CENTER) {
			armyKind = ARMY_SWORDSMAN;
		}
		
		// 사격소의 경우 궁수를 생산합니다.
		else if (building.kind == BUILDING_TRAINING_CENTER) {
			armyKind = ARMY_ARCHER;
		}
		
		// 마굿간의 경우 기마병을 생산합니다.
		else if (building.kind == BUILDING_STABLE) {
			armyKind = ARMY_CAVALY;
		}
		
		else {
			revert();
		}
		
		Material memory material = unitMaterials[armyKind];
		
		// 부대를 생성하는데 필요한 자원이 충분한지 확인합니다.
		require(
			wood.balanceOf(msg.sender) >= material.wood.mul(unitCount) &&
			stone.balanceOf(msg.sender) >= material.stone.mul(unitCount) &&
			iron.balanceOf(msg.sender) >= material.iron.mul(unitCount) &&
			ducat.balanceOf(msg.sender) >= material.ducat.mul(unitCount)
		);
		
		uint armyId = armies.push(Army({
			kind : armyKind,
			unitCount : unitCount,
			col : building.col,
			row : building.row,
			owner : msg.sender,
			createTime : now
		})).sub(1);
		
		positionToArmyIds[building.col][building.row].push(armyId);
		
		// 자원을 Delight로 이전합니다.
		wood.transferFrom(msg.sender, address(this), material.wood.mul(unitCount));
		stone.transferFrom(msg.sender, address(this), material.stone.mul(unitCount));
		iron.transferFrom(msg.sender, address(this), material.iron.mul(unitCount));
		ducat.transferFrom(msg.sender, address(this), material.ducat.mul(unitCount));
		
		return armyId;
	}
}