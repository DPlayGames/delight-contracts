pragma solidity ^0.5.9;

import "./DelightBuildingManager.sol";
import "./DelightArmyManager.sol";
import "./DelightItemManager.sol";
import "./Util/SafeMath.sol";

contract Delight is DelightBuildingManager, DelightArmyManager, DelightItemManager {
	using SafeMath for uint;
	
	uint constant private ORDER_BUILD = 0;
	uint constant private ORDER_UPGRADE_HQ = 1;
	uint constant private ORDER_CREATE_ARMY = 2;
	uint constant private ORDER_MOVE_AND_ATTACK = 3;
	uint constant private ORDER_RANGED_ATTACK = 4;
	uint constant private ORDER_CREATE_ITEM = 5;
	uint constant private ORDER_ATTACH_ITEM = 6;
	
	// 명령 큐를 실행합니다.
	function runOrderQueue(uint[] calldata orders, uint[] calldata params1, uint[] calldata params2, uint[] calldata params3, uint[] calldata params4) external {
		
		for (uint i = 0; i < orders.length; i += 1) {
			
			// 건물을 짓습니다.
			if (orders[i] == ORDER_BUILD) {
				build(params1[i], params2[i], params3[i]);
			}
			
			// 본부를 업그레이드합니다.
			if (orders[i] == ORDER_UPGRADE_HQ) {
				upgradeHQ(params1[i]);
			}
			
			// 부대를 생산합니다.
			else if (orders[i] == ORDER_CREATE_ARMY) {
				createArmy(params1[i], params2[i]);
			}
			
			// 부대를 이동시키고, 해당 지역에 적이 있으면 공격합니다.
			else if (orders[i] == ORDER_MOVE_AND_ATTACK) {
				moveAndAttack(params1[i], params2[i], params3[i], params4[i]);
			}
			
			// 원거리 유닛으로 특정 지역을 공격합니다.
			else if (orders[i] == ORDER_RANGED_ATTACK) {
				rangedAttack(params1[i], params2[i], params3[i], params4[i]);
			}
			
			// 아이템을 생산합니다.
			else if (orders[i] == ORDER_CREATE_ITEM) {
				createItem(params1[i], params2[i]);
			}
			
			// 아이템을 장착합니다.
			else if (orders[i] == ORDER_ATTACH_ITEM) {
				attachItem(params1[i], params2[i], params3[i]);
			}
		}
	}
}