pragma solidity ^0.5.9;

import "./DelightBase.sol";
import "./Util/SafeMath.sol";

contract DelightBuildingManager is DelightBase {
	using SafeMath for uint;
	
	// 건물을 짓습니다.
	function build(uint kind, uint col, uint row) internal returns (uint) {
		
		// 올바른 범위인지 체크합니다.
		require(col < COL_RANGE && row < ROW_RANGE);
		
		// 필드에 건물이 존재하면 안됩니다.
		require(positionToBuildingId[col][row] == 0);
		
		// 필드에 적군이 존재하면 안됩니다.
		require(positionToArmyIds[col][row].length == 0 || getArmyOwnerByPosition(col, row) == msg.sender);
		
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
		require(ownerToHQIds[msg.sender].length == 0 || existsHQAround == true ||
		// 본부인 경우, 내 병사가 있는 위치에 지을 수 있습니다.
		(
			kind == BUILDING_HQ &&
			positionToArmyIds[col][row].length > 0 &&
			getArmyOwnerByPosition(col, row) == msg.sender
		));
		
		Material memory material = buildingMaterials[kind];
		
		// 건물을 짓는데 필요한 자원이 충분한지 확인합니다.
		require(
			wood.balanceOf(msg.sender) >= material.wood &&
			stone.balanceOf(msg.sender) >= material.stone &&
			iron.balanceOf(msg.sender) >= material.iron &&
			ducat.balanceOf(msg.sender) >= material.ducat
		);
		
		uint bulidTime = now;
		
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
		
		emit Build(msg.sender, buildingId, kind, col, row, bulidTime);
		
		return buildingId;
	}
	
	// 본부를 업그레이드합니다.
	function upgradeHQ(uint buildingId) internal {
		
		Building storage building = buildings[buildingId];
		
		require(building.kind == BUILDING_HQ);
		
		// 최대 레벨은 2입니다. (0 ~ 2)
		require(building.level < 2);
		
		building.level += 1;
		
		emit UpgradeHQ(building.owner, buildingId, building.level, building.col, building.row);
	}
	
	// 건물에서 부대를 생산합니다.
	function createArmy(uint buildingId, uint unitCount) internal returns (uint) {
		
		Building memory building = buildings[buildingId];
		
		// 건물 소유주만 부대 생산이 가능합니다.
		require(building.owner == msg.sender);
		
		// 건물이 위치한 곳의 총 유닛 숫자를 계산합니다.
		uint[] storage armyIds = positionToArmyIds[building.col][building.row];
		
		uint totalUnitCount = unitCount;
		for (uint i = 0; i < armyIds.length; i += 1) {
			totalUnitCount = totalUnitCount.add(armies[armyIds[i]].unitCount);
		}
		
		// 건물이 위치한 곳의 총 유닛 숫자가 최대 유닛 수를 넘기면 안됩니다.
		require(totalUnitCount <= MAX_POSITION_UNIT_COUNT);
		
		uint unitKind;
		
		// 본부의 경우 기사를 생산합니다.
		if (building.kind == BUILDING_HQ) {
			
			// 이미 기사가 존재하는 곳이면, 취소합니다.
			if (armyIds.length == UNIT_KIND_COUNT && armyIds[UNIT_KNIGHT] != 0) {
				revert();
			} else {
				unitKind = UNIT_KNIGHT;
			}
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
		
		Material memory material = unitMaterials[unitKind];
		
		// 부대를 생성하는데 필요한 자원이 충분한지 확인합니다.
		require(
			wood.balanceOf(msg.sender) >= material.wood.mul(unitCount) &&
			stone.balanceOf(msg.sender) >= material.stone.mul(unitCount) &&
			iron.balanceOf(msg.sender) >= material.iron.mul(unitCount) &&
			ducat.balanceOf(msg.sender) >= material.ducat.mul(unitCount)
		);
		
		armyIds.length = UNIT_KIND_COUNT;
		
		// 기존에 부대가 존재하면 부대원의 숫자 증가
		uint originArmyId = armyIds[unitKind];
		uint newArmyId;
		uint createTime;
		
		if (originArmyId != 0) {
			armies[originArmyId].unitCount = armies[originArmyId].unitCount.add(unitCount);
		}
		
		// 새 부대 생성
		else {
			
			createTime = now;
			
			newArmyId = armies.push(Army({
				unitKind : unitKind,
				unitCount : unitCount,
				knightItemId : 0,
				col : building.col,
				row : building.row,
				owner : msg.sender,
				createTime : createTime
			})).sub(1);
			
			armyIds[unitKind] = newArmyId;
		}
		
		// 자원을 Delight로 이전합니다.
		wood.transferFrom(msg.sender, address(this), material.wood.mul(unitCount));
		stone.transferFrom(msg.sender, address(this), material.stone.mul(unitCount));
		iron.transferFrom(msg.sender, address(this), material.iron.mul(unitCount));
		ducat.transferFrom(msg.sender, address(this), material.ducat.mul(unitCount));
		
		if (originArmyId != 0) {
			
			emit AddUnits(msg.sender, originArmyId, unitKind, unitCount, building.col, building.row);
			
			return originArmyId;
		}
		
		else {
			
			emit CreateArmy(msg.sender, newArmyId, unitKind, unitCount, building.col, building.row, createTime);
			
			return newArmyId;
		}
	}
}