pragma solidity ^0.5.9;

import "./DelightBase.sol";
import "./Util/SafeMath.sol";

contract DelightBuildingManager is DelightBase {
	using SafeMath for uint;
	
	// 건물을 짓습니다.
	function build(uint kind, uint col, uint row) checkRange(col, row) internal returns (uint buildingId) {
		
	}
	
	// 건물에서 부대를 생산합니다.
	function createArmy(uint buildingId, uint kind) internal returns (uint armyId) {
		
	}
}