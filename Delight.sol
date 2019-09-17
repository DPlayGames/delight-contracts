pragma solidity ^0.5.9;

import "./DelightInterface.sol";
import "./DelightBase.sol";
import "./DelightInfoInterface.sol";
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
	
	// 기사의 기본 버프 데미지
	uint constant private KNIGHT_DEFAULT_BUFF_DAMAGE = 5;
	
	Record[] private history;
	
	DelightInfoInterface private info;
	DelightKnightItem private knightItem;
	
	DelightBuildingManager private buildingManager;
	DelightArmyManager private armyManager;
	DelightItemManager private itemManager;
	
	constructor() NetworkChecker() public {
		
		if (network == Network.Mainnet) {
			//TODO
		}
		
		else if (network == Network.Kovan) {
			
			// 정보
			info = DelightInfoInterface(0x27dd4D781d69b0739Cd6bFb77A9cBc0419171167);
			
			// 기사 아이템
			knightItem = DelightKnightItem(0x0c3ad341A711ECC43Ce5f18f0337F20A5861a60B);
			
			// 관리자들
			buildingManager	= DelightBuildingManager(0x0f3B145F0C104C42d522f9c188faE90239c2B2Bd);
			armyManager		= DelightArmyManager(0xB1cA4eE80181E196F1dA39D44299D180B63b8018);
			itemManager		= DelightItemManager(0xfc3e9D36FD84040299800D02f5bFa4d7e41313C2);
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
	
	// 전체 데미지를 가져옵니다.
	function getTotalDamage(uint distance, uint col, uint row) view public returns (uint) {
		
		uint totalDamage = 0;
		
		uint[] memory armyIds = armyManager.getPositionArmyIds(col, row);
		
		if (armyIds.length == UNIT_KIND_COUNT) {
			
			(
				,
				,
				uint knightItemId,
				,
				,
				,
				
			) = armyManager.getArmyInfo(armyIds[UNIT_KNIGHT]);
			
			// 총 공격력을 계산합니다.
			for (uint i = 0; i < UNIT_KIND_COUNT; i += 1) {
				
				(
					uint armyUnitKind,
					uint armyUnitCount,
					uint armyKnightItemId,
					,
					,
					,
					
				) = armyManager.getArmyInfo(armyIds[i]);
				
				if (
				// 유닛의 개수가 0개 이상이어야 합니다.
				armyUnitCount > 0 &&
				
				// 이동이 가능한 거리인지 확인합니다.
				distance <= info.getUnitMovableDistance(armyUnitKind)) {
					
					// 아군의 공격력 추가
					totalDamage = totalDamage.add(
						info.getUnitDamage(armyUnitKind).add(
							
							// 기사인 경우 기사 아이템의 공격력을 추가합니다.
							i == UNIT_KNIGHT ? knightItem.getItemDamage(armyKnightItemId) : (
								
								// 기사가 아닌 경우 기사의 버프 데미지를 추가합니다.
								armyIds[UNIT_KNIGHT] != 0 == true ? KNIGHT_DEFAULT_BUFF_DAMAGE + knightItem.getItemBuffDamage(knightItemId) : 0
							)
							
						).mul(armyUnitCount)
					);
				}
			}
		}
		
		return totalDamage;
	}
	
	// 전체 원거리 데미지를 가져옵니다.
	function getTotalRangedDamage(uint distance, uint col, uint row) view public returns (uint) {
		
		uint totalDamage = 0;
		
		uint[] memory armyIds = armyManager.getPositionArmyIds(col, row);
		
		if (armyIds.length == UNIT_KIND_COUNT) {
			
			(
				,
				,
				uint knightItemId,
				,
				,
				,
				
			) = armyManager.getArmyInfo(armyIds[UNIT_KNIGHT]);
			
			// 총 공격력을 계산합니다.
			for (uint i = 0; i < UNIT_KIND_COUNT; i += 1) {
				
				(
					uint armyUnitKind,
					uint armyUnitCount,
					uint armyKnightItemId,
					,
					,
					,
					
				) = armyManager.getArmyInfo(armyIds[i]);
				
				if (
				// 유닛의 개수가 0개 이상이어야 합니다.
				armyUnitCount > 0 &&
				
				// 공격이 가능한 거리인지 확인합니다.
				distance <= info.getUnitAttackableDistance(armyUnitKind)) {
					
					// 아군의 공격력 추가
					totalDamage = totalDamage.add(
						info.getUnitDamage(armyUnitKind).add(
							
							// 기사인 경우 기사 아이템의 공격력을 추가합니다.
							i == UNIT_KNIGHT ? knightItem.getItemDamage(armyKnightItemId) : (
								
								// 기사가 아닌 경우 기사의 버프 데미지를 추가합니다.
								armyIds[UNIT_KNIGHT] != 0 == true ? KNIGHT_DEFAULT_BUFF_DAMAGE + knightItem.getItemBuffDamage(knightItemId) : 0
							)
							
						).mul(armyUnitCount)
					);
				}
			}
		}
		
		return totalDamage;
	}
	
	// 부대를 이동시키고, 해당 지역에 적이 있으면 공격합니다.
	function moveAndAttack(uint fromCol, uint fromRow, uint toCol, uint toRow, Record memory record) private {
		
		require(fromCol < COL_RANGE && fromCol < ROW_RANGE);
		require(toCol < COL_RANGE && toCol < ROW_RANGE);
		
		require(msg.sender == armyManager.getPositionOwner(fromCol, fromRow));
		
		address enemy = armyManager.getPositionOwner(toCol, toRow);
		
		// 아무도 없는 곳이면 부대를 이동합니다.
		if (enemy == address(0x0)) {
			armyManager.moveArmy(fromCol, fromRow, toCol, toRow);
		}
		
		// 아군이면 부대를 통합합니다.
		else if (enemy == msg.sender) {
			armyManager.mergeArmy(fromCol, fromRow, toCol, toRow);
		}
		
		// 적군이면 전투를 개시합니다.
		else {
			
			// 거리 계산
			uint distance = (fromCol < toCol ? toCol - fromCol : fromCol - toCol) + (fromRow < toRow ? toRow - fromRow : fromRow - toRow);
			
			uint totalDamage = getTotalDamage(distance, fromCol, fromRow);
			uint totalEnemyDamage = getTotalDamage(0, toCol, toRow);
			
			uint battleId = history.length;
			
			record.kill = armyManager.attack(battleId, totalDamage, 0, toCol, toRow);
			record.death = armyManager.attack(battleId, totalEnemyDamage, distance, fromCol, fromRow);
			
			// 적진을 점령했다면, 병사들을 이동시킵니다.
			if (armyManager.getPositionOwner(toCol, toRow) == address(0x0)) {
				armyManager.moveArmy(fromCol, fromRow, toCol, toRow);
				armyManager.destroyBuilding(battleId, toCol, toRow);
				armyManager.win(battleId, msg.sender);
				record.isWin = true;
			}
			
			// 상대가 승리했습니다.
			else {
				armyManager.win(battleId, enemy);
			}
		}
	}
	
	// 원거리 유닛으로 특정 지역을 공격합니다.
	function rangedAttack(uint fromCol, uint fromRow, uint toCol, uint toRow, Record memory record) private {
		
		require(fromCol < COL_RANGE && fromCol < ROW_RANGE);
		require(toCol < COL_RANGE && toCol < ROW_RANGE);
		
		require(msg.sender == armyManager.getPositionOwner(fromCol, fromRow));
		
		address enemy = armyManager.getPositionOwner(toCol, toRow);
		
		// 아군은 공격할 수 없습니다.
		require(enemy != msg.sender);
		
		// 거리 계산
		uint distance = (fromCol < toCol ? toCol - fromCol : fromCol - toCol) + (fromRow < toRow ? toRow - fromRow : fromRow - toRow);
		
		uint totalDamage = getTotalRangedDamage(distance, fromCol, fromRow);
		uint totalEnemyDamage = getTotalRangedDamage(distance, toCol, toRow);
		
		record.kill = armyManager.rangedAttack(totalDamage, distance, toCol, toRow);
		record.death = armyManager.rangedAttack(totalEnemyDamage, distance, fromCol, fromRow);
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
				buildingManager.build(msg.sender, params1[i], params2[i], params3[i]);
			}
			
			// 본부를 업그레이드합니다.
			if (orders[i] == ORDER_UPGRADE_HQ) {
				buildingManager.upgradeHQ(msg.sender, params1[i]);
			}
			
			// 부대를 생산합니다.
			else if (orders[i] == ORDER_CREATE_ARMY) {
				buildingManager.createArmy(msg.sender, params1[i], params2[i]);
			}
			
			// 아이템을 생산합니다.
			else if (orders[i] == ORDER_CREATE_ITEM) {
				itemManager.createItem(msg.sender, params1[i], params2[i]);
			}
			
			// 아이템을 장착합니다.
			else if (orders[i] == ORDER_ATTACH_ITEM) {
				armyManager.attachItem(msg.sender, params1[i], params2[i], params3[i]);
			}
			
			// 아이템을 장착합니다.
			else if (orders[i] == ORDER_ATTACH_KNIGHT_ITEM) {
				armyManager.attachKnightItem(msg.sender, params1[i], params2[i]);
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