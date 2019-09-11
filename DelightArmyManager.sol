pragma solidity ^0.5.9;

import "./DelightBase.sol";
import "./DelightItem.sol";
import "./Util/SafeMath.sol";

contract DelightArmyManager is DelightBase {
	using SafeMath for uint;
	
	// 부대를 이동시키고, 해당 지역에 적이 있으면 공격합니다.
	function moveAndAttack(uint col, uint row, uint toCol, uint toRow) checkRange(col, row) checkRange(toCol, toRow) internal {
		//TODO:
	}
	
	// 원거리 유닛으로 특정 지역을 공격합니다.
	function rangedAttack(uint col, uint row, uint toCol, uint toRow) checkRange(col, row) checkRange(toCol, toRow) internal {
		//TODO:
	}
	
	// 부대에 아이템을 장착합니다.
	function attachItem(uint armyId, uint itemKind, uint unitCount) internal {
		
		Army storage army = armies[armyId];
		
		// 유닛 수가 충분한지 확인합니다.
		require(army.unitCount >= unitCount);
		
		DelightItem itemContract = getItemContract(itemKind);
		
		// 아이템 수가 충분한지 확인합니다.
		require(itemContract.balanceOf(msg.sender) >= unitCount);
		
		// 부대의 성격과 아이템의 성격이 일치한지 확인합니다.
		require(
			// 검병
			(
				army.kind == ARMY_SWORDSMAN &&
				(
					itemKind == ITEM_AXE ||
					itemKind == ITEM_SPEAR ||
					itemKind == ITEM_SHIELD ||
					itemKind == ITEM_HOOD
				)
			) ||
			
			// 궁수
			(
				army.kind == ARMY_ARCHER &&
				(
					itemKind == ITEM_CROSSBOW ||
					itemKind == ITEM_BALLISTA ||
					itemKind == ITEM_CATAPULT
				)
			) ||
			
			// 기마병
			(
				army.kind == ARMY_CAVALY &&
				(
					itemKind == ITEM_CAMEL ||
					itemKind == ITEM_ELEPHANT
				)
			)
		);
		
		// 유닛의 일부를 변경하여 새로운 부대를 생성합니다.
		
		// 새 부대의 성격
		uint armyKind;
		
		if (itemKind == ITEM_AXE) {
			armyKind = ARMY_AXEMAN;
		} else if (itemKind == ITEM_SPEAR) {
			armyKind = ARMY_SPEARMAN;
		} else if (itemKind == ITEM_SHIELD) {
			armyKind = ARMY_SHIELDMAN;
		} else if (itemKind == ITEM_HOOD) {
			armyKind = ARMY_SPY;
		}
		
		else if (itemKind == ITEM_CROSSBOW) {
			armyKind = ARMY_CROSSBOWMAN;
		} else if (itemKind == ITEM_BALLISTA) {
			armyKind = ARMY_BALLISTA;
		} else if (itemKind == ITEM_CATAPULT) {
			armyKind = ARMY_CATAPULT;
		}
		
		else if (itemKind == ITEM_CAMEL) {
			armyKind = ARMY_CAMELRY;
		} else if (itemKind == ITEM_ELEPHANT) {
			armyKind = ARMY_WAR_ELEPHANT;
		}
		
		// 숫자가 완전히 동일하면 부대의 성격을 변경합니다.
		if (army.unitCount == unitCount) {
			army.kind = armyKind;
		}
		
		// 숫자가 다르면 새 부대를 생성합니다.
		else {
			army.unitCount = army.unitCount.sub(unitCount);
			
			uint newArmyId = armies.push(Army({
				kind : armyKind,
				unitCount : unitCount,
				col : army.col,
				row : army.row,
				owner : msg.sender,
				createTime : now
			})).sub(1);
			
			positionToArmyIds[army.col][army.row].push(newArmyId);
		}
		
		// 아이템을 Delight로 이전합니다.
		itemContract.transferFrom(msg.sender, address(this), unitCount);
	}
}