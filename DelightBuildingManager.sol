pragma solidity ^0.5.9;

import "./DelightBase.sol";
import "./Util/SafeMath.sol";

contract DelightBuildingManager is DelightBase {
	using SafeMath for uint;
	
	modifier checkBuildingMaterial(uint kind) {
		
		Material memory material = buildingMaterials[kind];
		
		require(wood.balanceOf(msg.sender) >= material.wood);
		_;
	}
	
	// 건물을 짓습니다.
	function build(uint kind, uint col, uint row)
	checkRange(col, row)
	checkBuildingMaterial(kind)
	internal returns (uint buildingId) {
		
		// 필드에 건물이 존재하는가?
		if (positionToBuildingId[col][row] != 0) {
			//TODO:
		}
		
		// 필드에 적군이 존재하는가?
		else if (positionToArmyIds[col][row].length == 0 || armyIdToOwner[positionToArmyIds[col][row][0]] != msg.sender) {
			
		}
		
		// 가격은 충분한가?
	}
	
	// 건물에서 부대를 생산합니다.
	function createArmy(uint buildingId, uint kind) internal returns (uint armyId) {
		
	}
}