pragma solidity ^0.5.9;

import "./DelightInterface.sol";
import "./DelightBase.sol";
import "./DelightBuildingManager.sol";
import "./DelightArmyManager.sol";
import "./DelightItemManager.sol";
import "./Util/NetworkChecker.sol";
import "./Util/SafeMath.sol";

contract Delight is DelightInterface, DelightBase, NetworkChecker {
	using SafeMath for uint;
    
	uint constant private ORDER_BUILD				= 0;
	uint constant private ORDER_UPGRADE_HQ			= 1;
	uint constant private ORDER_CREATE_ARMY			= 2;
	uint constant private ORDER_CREATE_ITEM			= 3;
	uint constant private ORDER_ATTACH_ITEM			= 4;
	uint constant private ORDER_ATTACH_KNIGHT_ITEM	= 5;
	uint constant private ORDER_MOVE_AND_ATTACK		= 6;
	uint constant private ORDER_RANGED_ATTACK		= 7;
	
	Record[] private history;
	
	DelightBuildingManager internal delightBuildingManager;
	DelightArmyManager internal delightArmyManager;
	DelightItemManager internal delightItemManager;
	
	constructor() NetworkChecker() public {
		
		if (network == Network.Mainnet) {
			//TODO
		}
		
		else if (network == Network.Kovan) {
			//TODO
			delightBuildingManager	= DelightBuildingManager(0x912E5Ca9DdC900beBa2317F3e2C36BFf54E0388f);
			delightArmyManager		= DelightArmyManager(0x7A4bE3df50A4e2454ABf12b01376c5DAB09Bc7d7);
			delightItemManager		= DelightItemManager(0xDCfC9092dA44FA9C7c7d63D151702FEC529f84B9);
		}
		
		else if (network == Network.Ropsten) {
			//TODO
		}
		
		else if (network == Network.Rinkeby) {
			//TODO
		}
		
		else {
			revert();
		}
	}
	
	// 부대를 이동시키고, 해당 지역에 적이 있으면 공격합니다.
	function moveAndAttack(uint fromCol, uint fromRow, uint toCol, uint toRow, Record memory record) internal {
		
		require(fromCol < COL_RANGE && fromCol < ROW_RANGE);
		require(toCol < COL_RANGE && toCol < ROW_RANGE);
		
		require(msg.sender == delightArmyManager.getPositionOwner(fromCol, fromRow));
		
		address enemy = delightArmyManager.getPositionOwner(toCol, toRow);
		
		// 아무도 없는 곳이면 부대를 이동합니다.
		if (enemy == address(0x0)) {
			delightArmyManager.moveArmy(fromCol, fromRow, toCol, toRow);
		}
		
		// 아군이면 부대를 통합합니다.
		else if (enemy == msg.sender) {
			delightArmyManager.mergeArmy(fromCol, fromRow, toCol, toRow);
		}
		
		// 적군이면 전투를 개시합니다.
		else {
			
			// 거리 계산
			uint distance = (fromCol < toCol ? toCol - fromCol : fromCol - toCol) + (fromRow < toRow ? toRow - fromRow : fromRow - toRow);
			
			uint totalDamage = delightArmyManager.getTotalDamage(distance, fromCol, fromRow);
			uint totalEnemyDamage = delightArmyManager.getTotalDamage(0, toCol, toRow);
			
			uint battleId = history.length;
			
			record.kill = delightArmyManager.attack(battleId, totalDamage, 0, toCol, toRow);
			record.death = delightArmyManager.attack(battleId, totalEnemyDamage, distance, fromCol, fromRow);
			
			// 적진을 점령했다면, 병사들을 이동시킵니다.
			if (delightArmyManager.getPositionOwner(toCol, toRow) == address(0x0)) {
				delightArmyManager.moveArmy(fromCol, fromRow, toCol, toRow);
				delightArmyManager.destroyBuilding(battleId, toCol, toRow);
				delightArmyManager.win(battleId, msg.sender);
				record.isWin = true;
			}
			
			// 상대가 승리했습니다.
			else {
				delightArmyManager.win(battleId, enemy);
			}
		}
	}
	
	// 원거리 유닛으로 특정 지역을 공격합니다.
	function rangedAttack(uint fromCol, uint fromRow, uint toCol, uint toRow, Record memory record) internal {
		
		require(fromCol < COL_RANGE && fromCol < ROW_RANGE);
		require(toCol < COL_RANGE && toCol < ROW_RANGE);
		
		require(msg.sender == delightArmyManager.getPositionOwner(fromCol, fromRow));
		
		address enemy = delightArmyManager.getPositionOwner(toCol, toRow);
		
		// 아군은 공격할 수 없습니다.
		require(enemy != msg.sender);
		
		// 거리 계산
		uint distance = (fromCol < toCol ? toCol - fromCol : fromCol - toCol) + (fromRow < toRow ? toRow - fromRow : fromRow - toRow);
		
		uint totalDamage = delightArmyManager.getTotalRangedDamage(distance, fromCol, fromRow);
		uint totalEnemyDamage = delightArmyManager.getTotalRangedDamage(distance, toCol, toRow);
		
		record.kill = delightArmyManager.rangedAttack(totalDamage, distance, toCol, toRow);
		record.death = delightArmyManager.rangedAttack(totalEnemyDamage, distance, fromCol, fromRow);
	}
	
	// 명령 큐를 실행합니다.
	function runOrderQueue(uint[] calldata orders, uint[] calldata params1, uint[] calldata params2, uint[] calldata params3, uint[] calldata params4) external {
		
		for (uint i = 0; i < orders.length; i += 1) {
			
			Record memory record = Record({
				order : orders[i],
				account : msg.sender,
				param1 : params1[i],
				param2 : params2[i],
				param3 : params3[i],
				param4 : params4[i],
				kill : 0,
				death : 0,
				isWin : false,
				time : now
			});
			
			// 건물을 짓습니다.
			if (orders[i] == ORDER_BUILD) {
				delightBuildingManager.build(msg.sender, params1[i], params2[i], params3[i]);
			}
			
			// 본부를 업그레이드합니다.
			if (orders[i] == ORDER_UPGRADE_HQ) {
				delightBuildingManager.upgradeHQ(msg.sender, params1[i]);
			}
			
			// 부대를 생산합니다.
			else if (orders[i] == ORDER_CREATE_ARMY) {
				delightBuildingManager.createArmy(msg.sender, params1[i], params2[i]);
			}
			
			// 아이템을 생산합니다.
			else if (orders[i] == ORDER_CREATE_ITEM) {
				delightItemManager.createItem(msg.sender, params1[i], params2[i]);
			}
			
			// 아이템을 장착합니다.
			else if (orders[i] == ORDER_ATTACH_ITEM) {
				delightArmyManager.attachItem(msg.sender, params1[i], params2[i], params3[i]);
			}
			
			// 아이템을 장착합니다.
			else if (orders[i] == ORDER_ATTACH_KNIGHT_ITEM) {
				delightArmyManager.attachKnightItem(msg.sender, params1[i], params2[i]);
			}
			
			// 부대를 이동시키고, 해당 지역에 적이 있으면 공격합니다.
			else if (orders[i] == ORDER_MOVE_AND_ATTACK) {
				moveAndAttack(params1[i], params2[i], params3[i], params4[i], record);
			}
			
			// 원거리 유닛으로 특정 지역을 공격합니다.
			else if (orders[i] == ORDER_RANGED_ATTACK) {
				rangedAttack(params1[i], params2[i], params3[i], params4[i], record);
			}
			
			else {
				revert();
			}
			
			// 기록을 추가합니다.
			history.push(record);
		}
	}
}