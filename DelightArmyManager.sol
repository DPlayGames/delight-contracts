pragma solidity ^0.5.9;

import "./DelightBase.sol";
import "./Util/SafeMath.sol";

contract DelightArmyManager is DelightBase {
	using SafeMath for uint;
	
	// 부대를 이동시킵니다.
	function moveArmy(uint armyId, uint toCol, uint toRow) checkRange(toCol, toRow) internal {
		
	}
	
	// 전투를 개시합니다.
	function battle() internal {
		
	}
}