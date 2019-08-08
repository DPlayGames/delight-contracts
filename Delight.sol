pragma solidity ^0.5.9;

import "./DelightBase.sol";
import "./Util/SafeMath.sol";

contract Delight is DelightBase {
	using SafeMath for uint;
	
	uint constant private ORDER_BUILD = 0;
	uint constant private ORDER_CREATE_ARMY = 1;
	
	// 건물을 짓습니다.
	function build(uint kind, uint col, uint row) internal returns (uint buildingId) {
		
	}
	
	// 건물에서 부대를 생산합니다.
	function createArmy(uint buildingId, uint kind) internal returns (uint armyId) {
		
	}
	
	// 부대를 이동시킵니다.
	function moveArmy(uint armyId, uint toCol, uint toRow) internal {
		
	}
	
	// 전투를 개시합니다.
	function battle() internal {
		
	}
	
	// 명령 큐를 실행합니다.
	function runOrderQueue(uint[] calldata orders, uint[] calldata params1, uint[] calldata params2, uint[] calldata params3) external {
		
		for (uint i = 0; i < orders.length; i += 1) {
			
			// 건물을 짓습니다.
			if (orders[i] == ORDER_BUILD) {
				build(params1[i], params2[i], params3[i]);
			}
			
			// 유닛을 생산합니다.
			else if (orders[i] == ORDER_CREATE_ARMY) {
				createArmy(params1[i], params2[i]);
			}
		}
	}
}