pragma solidity ^0.5.9;

import "./DelightWorldInterface.sol";
import "./DelightHistoryInterface.sol";
import "./DelightBase.sol";
import "./Util/SafeMath.sol";

contract Delight is DelightBase {
	using SafeMath for uint;
	
	// Events
	// 이벤트
	event Move	(address indexed owner, uint fromCol, uint fromRow, uint toCol, uint toRow);
    event Merge	(address indexed owner, uint fromCol, uint fromRow, uint toCol, uint toRow);
    
	uint constant private ORDER_BUILD				= 0;
	uint constant private ORDER_UPGRADE_HQ			= 1;
	uint constant private ORDER_CREATE_ARMY			= 2;
	uint constant private ORDER_CREATE_ITEM			= 3;
	uint constant private ORDER_ATTACH_ITEM			= 4;
	uint constant private ORDER_ATTACH_KNIGHT_ITEM	= 5;
	uint constant private ORDER_MOVE_AND_ATTACK		= 6;
	uint constant private ORDER_RANGED_ATTACK		= 7;
	
	DelightWorldInterface private delightWorld;
	DelightHistoryInterface internal delightHistory;
	
	constructor() DelightBase() public {
		
		// DPlay History 스마트 계약을 불러옵니다.
		if (network == Network.Mainnet) {
			//TODO
		} else if (network == Network.Kovan) {
			//TODO
			delightWorld = DelightWorldInterface(0x0);
			delightHistory = DelightHistoryInterface(0x0);
		} else if (network == Network.Ropsten) {
			//TODO
		} else if (network == Network.Rinkeby) {
			//TODO
		} else {
			revert();
		}
	}
	
	// Sender가 부대의 소유주일때만 실행
	modifier onlyArmyOwner(uint col, uint row) {
		require(msg.sender == delightWorld.getArmyOwnerByPosition(col, row));
		_;
	}
	
	// 부대를 이동시키고, 해당 지역에 적이 있으면 공격합니다.
	function moveAndAttack(uint fromCol, uint fromRow, uint toCol, uint toRow) checkRange(fromCol, fromRow) checkRange(toCol, toRow) onlyArmyOwner(fromCol, fromRow) internal {
		
		address enemy = delightWorld.getArmyOwnerByPosition(toCol, toRow);
		
		// 아무도 없는 곳이면 부대를 이동합니다.
		if (enemy == address(0x0)) {
			
			delightWorld.moveArmy(fromCol, fromRow, toCol, toRow);
			
			// 기록을 저장합니다.
			delightHistory.recordMoveArmy(msg.sender, fromCol, fromRow, toCol, toRow);
			
			// 이벤트 발생
			emit Move(msg.sender, fromCol, fromRow, toCol, toRow);
		}
		
		// 아군이면 부대를 통합합니다.
		else if (enemy == msg.sender) {
			
			delightWorld.mergeArmy(fromCol, fromRow, toCol, toRow);
			
			// 기록을 저장합니다.
			delightHistory.recordMergeArmy(msg.sender, fromCol, fromRow, toCol, toRow);
			
			// 이벤트 발생
			emit Merge(msg.sender, fromCol, fromRow, toCol, toRow);
		}
		
		// 적군이면 전투를 개시합니다.
		else {
			
			// 거리 계산
			uint distance = (fromCol < toCol ? toCol - fromCol : fromCol - toCol) + (fromRow < toRow ? toRow - fromRow : fromRow - toRow);
			
			uint totalDamage = delightWorld.getTotalDamage(distance, fromCol, fromRow);
			uint totalEnemyDamage = delightWorld.getTotalDamage(0, toCol, toRow);
			
			// 전리품
			Material memory rewardMaterial = Material({
				wood : 0,
				stone : 0,
				iron : 0,
				ducat : 0
			});
		}
	}
	
	// 원거리 유닛으로 특정 지역을 공격합니다.
	function rangedAttack(uint fromCol, uint fromRow, uint toCol, uint toRow) checkRange(fromCol, fromRow) checkRange(toCol, toRow) onlyArmyOwner(fromCol, fromRow) internal {
		
		address enemy = delightWorld.getArmyOwnerByPosition(toCol, toRow);
		
		// 아군은 공격할 수 없습니다.
		require(enemy != msg.sender);
		
		//delightWorld.rangedAttack(fromCol, fromRow, toCol, toRow);
	}
	
	// 명령 큐를 실행합니다.
	function runOrderQueue(uint[] calldata orders, uint[] calldata params1, uint[] calldata params2, uint[] calldata params3, uint[] calldata params4) external {
		
		for (uint i = 0; i < orders.length; i += 1) {
			
			// 건물을 짓습니다.
			if (orders[i] == ORDER_BUILD) {
				delightWorld.build(msg.sender, params1[i], params2[i], params3[i]);
			}
			
			// 본부를 업그레이드합니다.
			if (orders[i] == ORDER_UPGRADE_HQ) {
				delightWorld.upgradeHQ(msg.sender, params1[i]);
			}
			
			// 부대를 생산합니다.
			else if (orders[i] == ORDER_CREATE_ARMY) {
				delightWorld.createArmy(msg.sender, params1[i], params2[i]);
			}
			
			// 아이템을 생산합니다.
			else if (orders[i] == ORDER_CREATE_ITEM) {
				delightWorld.createItem(msg.sender, params1[i], params2[i]);
			}
			
			// 아이템을 장착합니다.
			else if (orders[i] == ORDER_ATTACH_ITEM) {
				delightWorld.attachItem(msg.sender, params1[i], params2[i], params3[i]);
			}
			
			// 아이템을 장착합니다.
			else if (orders[i] == ORDER_ATTACH_KNIGHT_ITEM) {
				delightWorld.attachKnightItem(msg.sender, params1[i], params2[i]);
			}
			
			// 부대를 이동시키고, 해당 지역에 적이 있으면 공격합니다.
			else if (orders[i] == ORDER_MOVE_AND_ATTACK) {
				moveAndAttack(params1[i], params2[i], params3[i], params4[i]);
			}
			
			// 원거리 유닛으로 특정 지역을 공격합니다.
			else if (orders[i] == ORDER_RANGED_ATTACK) {
				rangedAttack(params1[i], params2[i], params3[i], params4[i]);
			}
		}
	}
}