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
		_;
	}
	
	// 건물을 짓는데 필요한 자원이 충분한지 확인합니다.
	modifier checkBuildingMaterial(uint kind) {
		
		Material memory material = buildingMaterials[kind];
		
		require(
			wood.balanceOf(msg.sender) >= material.wood &&
			stone.balanceOf(msg.sender) >= material.stone &&
			iron.balanceOf(msg.sender) >= material.iron &&
			ducat.balanceOf(msg.sender) >= material.ducat
		);
		_;
	}
	
	// 건물을 짓습니다.
	function build(uint kind, uint col, uint row)
	checkRange(col, row)
	checkBuildingPosition(col, row)
	checkBuildingMaterial(kind)
	internal returns (uint) {
		
		uint buildTime = now;
		
		uint buildingId = buildings.push(Building({
			kind : kind,
			col : col,
			row : row,
			owner : msg.sender,
			buildTime : buildTime
		})).sub(1);
		
		positionToBuildingId[col][row] = buildingId;
		
		Material memory material = buildingMaterials[kind];
		
		// 자원을 Delight로 이전합니다.
		wood.transferFrom(msg.sender, address(this), material.wood);
		stone.transferFrom(msg.sender, address(this), material.stone);
		iron.transferFrom(msg.sender, address(this), material.iron);
		ducat.transferFrom(msg.sender, address(this), material.ducat);
		
		return buildingId;
	}
	
	// 건물에서 부대를 생산합니다.
	function createArmy(uint buildingId, uint unitCount) internal returns (uint) {
		
		Building memory building = buildings[buildingId];
		
		// 건물 소유주만 부대 생산이 가능합니다.
		require(building.owner == msg.sender);
		
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
		
		uint createTime = now;
		
		uint armyId = armies.push(Army({
			kind : armyKind,
			unitCount : unitCount,
			col : building.col,
			row : building.row,
			owner : msg.sender,
			createTime : createTime
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