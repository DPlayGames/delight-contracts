pragma solidity ^0.5.9;

import "./DelightInterface.sol";
import "./DelightBase.sol";
import "./DelightInfoInterface.sol";
import "./DelightKnightItemInterface.sol";
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
	uint constant private ORDER_MOVE_ONE			= 6;
	uint constant private ORDER_MOVE_AND_ATTACK		= 7;
	uint constant private ORDER_RANGED_ATTACK		= 8;
	
	// Knight's default buff damage
	// 기사의 기본 버프 데미지
	uint constant private KNIGHT_DEFAULT_BUFF_DAMAGE = 5;
	
	DelightInfoInterface private info;
	DelightKnightItemInterface private knightItem;
	
	DelightBuildingManager private buildingManager;
	DelightArmyManager private armyManager;
	DelightItemManager private itemManager;
	
	constructor() NetworkChecker() public {
		
		if (network == Network.Mainnet) {
			//TODO
		}
		
		else if (network == Network.Kovan) {
			
			// information
			// 정보
			info = DelightInfoInterface(0x473b0CD0354C4cf9E2D7d5964963530D0c50ae3B);
			
			// knight item
			// 기사 아이템
			knightItem = DelightKnightItemInterface(0x27E124cf79348F06345C9D97F557743Cf485c9EA);
			
			// managers
			// 관리자들
			buildingManager	= DelightBuildingManager(0x4792562d90aD24A6D4cA088747AdD71a71bA73Ae);
			armyManager		= DelightArmyManager(0xbC39b9271b043AF40A34AA6B0DbC9811B5979Eea);
			itemManager		= DelightItemManager(0xe9108f2E2b4c60238Ff7a7ADe4Ec83E46e77c18a);
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
	
	Record[] private history;
	
	// Returns the total number of records.
	// 기록의 총 개수를 반환합니다.
	function getRecordCount() view external returns (uint) {
		return history.length;
	}
	
	// Returns a record.
	// 기록을 반환합니다.
	function getRecord(uint recordId) view external returns (
		uint order,
		address account,
		uint param1,
		uint param2,
		uint param3,
		uint param4,
		uint kill,
		uint death,
		bool isWin,
		uint time
	) {
		Record memory record = history[recordId];
		
		return (
			record.order,
			record.account,
			record.param1,
			record.param2,
			record.param3,
			record.param4,
			record.kill,
			record.death,
			record.isWin,
			record.time
		);
	}
	
	// Gets the total damage of an army.
	// 전체 데미지를 가져옵니다.
	function getTotalDamage(uint distance, uint col, uint row) view public returns (uint) {
		
		uint totalDamage = 0;
		
		uint[] memory armyIds = armyManager.getPositionArmyIds(col, row);
		
		(
			,
			,
			uint knightItemId,
			,
			,
			,
			
		) = armyManager.getArmyInfo(armyIds[UNIT_KNIGHT]);
		
		// Calculates the total damage.
		// 총 데미지를 계산합니다.
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
			// The number of units must be bigger than 0.
			// 유닛의 개수는 0보다 커야합니다.
			armyUnitCount > 0 &&
			
			// Checks if the unit can reach the distance.
			// 이동이 가능한 거리인지 확인합니다.
			distance <= info.getUnitMovableDistance(armyUnitKind)) {
				
				// Adds the total damage from the friendly army.
				// 아군의 데미지 추가
				totalDamage = totalDamage.add(
					info.getUnitDamage(armyUnitKind).add(
						
						// If the unit's a knight, add the knight item's damage .
						// 기사인 경우 기사 아이템의 데미지를 추가합니다.
						i == UNIT_KNIGHT ? knightItem.getItemDamage(armyKnightItemId) : (
							
							// If the unit's not a knight, add a knight's buff damage .
							// 기사가 아닌 경우 기사의 버프 데미지를 추가합니다.
							armyIds[UNIT_KNIGHT] != 0 ? KNIGHT_DEFAULT_BUFF_DAMAGE + knightItem.getItemBuffDamage(knightItemId) : 0
						)
						
					).add(
						
						// 이동 거리가 0일때만 병사 위치의 건물의 버프 데미지를 가져옵니다.
						distance == 0 ? buildingManager.getBuildingBuffDamage(col, row) : 0
						
					).mul(armyUnitCount)
				);
			}
		}
		
		return totalDamage;
	}
	
	// Gets the total ranged damage.
	// 전체 원거리 데미지를 가져옵니다.
	function getTotalRangedDamage(uint distance, uint col, uint row) view public returns (uint) {
		
		uint totalDamage = 0;
		
		uint[] memory armyIds = armyManager.getPositionArmyIds(col, row);
		
		(
			,
			,
			uint knightItemId,
			,
			,
			,
			
		) = armyManager.getArmyInfo(armyIds[UNIT_KNIGHT]);
		
		// Calcaultes the total damage.
		// 총 데미지를 계산합니다.
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
			
			// The number of units must be more than 0.
			// 유닛의 개수가 0개 이상이어야 합니다.
			armyUnitCount > 0 &&
			
			// Checks if the unit can reach the distance.
			// 공격이 가능한 거리인지 확인합니다.
			distance <= info.getUnitAttackableDistance(armyUnitKind)) {
				
				// Adds the damage from the friendly army.
				// 아군의 데미지 추가
				totalDamage = totalDamage.add(
					info.getUnitDamage(armyUnitKind).add(
						
						// If the unit's a knight, adds the knight item's damage 
						// 기사인 경우 기사 아이템의 공격력을 추가합니다.
						i == UNIT_KNIGHT ? knightItem.getItemDamage(armyKnightItemId) : (
							
							// If the unit's not a knight, adds a knight's buff damage 
							// 기사가 아닌 경우 기사의 버프 데미지를 추가합니다.
							armyIds[UNIT_KNIGHT] != 0 ? KNIGHT_DEFAULT_BUFF_DAMAGE + knightItem.getItemBuffDamage(knightItemId) : 0
						)
						
					).add(
						
						// 병사 위치의 건물의 버프 데미지를 가져옵니다.
						buildingManager.getBuildingBuffDamage(col, row)
						
					).mul(armyUnitCount)
				);
			}
		}
		
		return totalDamage;
	}
	
	// Army moves and attacks if there's enemy in the destination tile.
	// 부대를 이동시키고, 해당 지역에 적이 있으면 공격합니다.
	function moveAndAttack(uint fromCol, uint fromRow, uint toCol, uint toRow, Record memory record) private {
		
		// 위치가 달라야 합니다.
		require(fromCol != toCol || fromRow != toRow);
		
		// 범위 체크
		require(fromCol < COL_RANGE && fromCol < ROW_RANGE);
		require(toCol < COL_RANGE && toCol < ROW_RANGE);
		
		// 부대의 소유주인지 확인합니다.
		require(msg.sender == armyManager.getPositionOwner(fromCol, fromRow));
		
		address enemy = armyManager.getPositionOwner(toCol, toRow);
		
		// 아무도 없는 곳이거나 아군이면 부대를 이동시킵니다.
		if (enemy == address(0) || enemy == msg.sender) {
			armyManager.moveArmy(fromCol, fromRow, toCol, toRow);
		}
		
		// If there's a hostile army in the destination, attack.
		// 적군이면 전투를 개시합니다.
		else {
			
			// Calculates the distance.
			// 거리 계산
			uint distance = (fromCol < toCol ? toCol - fromCol : fromCol - toCol) + (fromRow < toRow ? toRow - fromRow : fromRow - toRow);
			
			uint totalDamage = getTotalDamage(distance, fromCol, fromRow);
			uint totalEnemyDamage = getTotalDamage(0, toCol, toRow);
			
			uint battleId = history.length;
			
			record.kill = armyManager.attack(battleId, totalDamage, 0, toCol, toRow);
			record.death = armyManager.attack(battleId, totalEnemyDamage, distance, fromCol, fromRow);
			
			// If the enemy building is captured, move the soldiers.
			// 적진을 점령했다면, 병사들을 이동시킵니다.
			if (armyManager.getPositionOwner(toCol, toRow) == address(0)) {
				armyManager.moveArmy(fromCol, fromRow, toCol, toRow);
				armyManager.destroyBuilding(battleId, toCol, toRow);
				armyManager.win(battleId, msg.sender);
				record.isWin = true;
			}
			
			// enemy won
			// 상대가 승리했습니다.
			else {
				armyManager.win(battleId, enemy);
			}
		}
	}
	
	// 단일 부대를 이동시킵니다.
	function moveOne(uint armyId, uint unitCount, uint toCol, uint toRow) private {
		
		// 범위 체크
		require(toCol < COL_RANGE && toCol < ROW_RANGE);
		
		// The number of units must be bigger than 0.
		// 유닛의 개수는 0보다 커야합니다.
		require(unitCount > 0);
		
		(
			uint armyUnitKind,
			uint armyUnitCount,
			,
			uint armyCol,
			uint armyRow,
			address armyOwner,
			
		) = armyManager.getArmyInfo(armyId);
		
		// 위치가 달라야 합니다.
		require(armyCol != toCol || armyRow != toRow);
		
		// 부대의 소유주인지 확인합니다.
		require(msg.sender == armyOwner);
		
		// 이동할 유닛의 개수가 부대에 존재하는 유닛의 개수보다 적거나 같아야합니다.
		require(unitCount <= armyUnitCount);
		
		// Check if the unit can reach the distance.
		// 이동이 가능한 거리인지 확인합니다.
		require((armyCol < toCol ? toCol - armyCol : armyCol - toCol) + (armyRow < toRow ? toRow - armyRow : armyRow - toRow) <= info.getUnitMovableDistance(armyUnitKind));
		
		address enemy = armyManager.getPositionOwner(toCol, toRow);
		
		// 아무도 없는 곳이거나 아군인 경우에만 가능합니다.
		require(enemy == address(0) || enemy == msg.sender);
		
		armyManager.moveArmyOne(armyManager.getTotalUnitCount(toCol, toRow), armyId, unitCount, toCol, toRow);
	}
	
	// Range unit attacks a given tile.
	// 원거리 유닛으로 특정 지역을 공격합니다.
	function rangedAttack(uint fromCol, uint fromRow, uint toCol, uint toRow, Record memory record) private {
		
		// 위치가 달라야 합니다.
		require(fromCol != toCol || fromRow != toRow);
		
		// 범위 체크
		require(fromCol < COL_RANGE && fromCol < ROW_RANGE);
		require(toCol < COL_RANGE && toCol < ROW_RANGE);
		
		// 부대의 소유주인지 확인합니다.
		require(msg.sender == armyManager.getPositionOwner(fromCol, fromRow));
		
		address enemy = armyManager.getPositionOwner(toCol, toRow);
		
		// Cannot attack friendly force.
		// 아군은 공격할 수 없습니다.
		require(enemy != msg.sender);
		
		// Calculates the distance.
		// 거리 계산
		uint distance = (fromCol < toCol ? toCol - fromCol : fromCol - toCol) + (fromRow < toRow ? toRow - fromRow : fromRow - toRow);
		
		uint totalDamage = getTotalRangedDamage(distance, fromCol, fromRow);
		uint totalEnemyDamage = getTotalRangedDamage(distance, toCol, toRow);
		
		record.kill = armyManager.rangedAttack(totalDamage, toCol, toRow);
		record.death = armyManager.rangedAttack(totalEnemyDamage, fromCol, fromRow);
	}
	
	// Executes the order que.
	// 명령 큐를 실행합니다.
	function runOrderQueue(uint[] calldata orders, uint[] calldata params1, uint[] calldata params2, uint[] calldata params3, uint[] calldata params4) external {
		
		require(orders.length > 0);
		
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
			
			// Build buildings.
			// 건물을 짓습니다.
			if (orders[i] == ORDER_BUILD) {
				buildingManager.build(msg.sender, params1[i], params2[i], params3[i]);
			}
			
			// Upgrades headquarters
			// 본부를 업그레이드합니다.
			else if (orders[i] == ORDER_UPGRADE_HQ) {
				buildingManager.upgradeHQ(msg.sender, params1[i]);
			}
			
			// Creates armies.
			// 부대를 생산합니다.
			else if (orders[i] == ORDER_CREATE_ARMY) {
				buildingManager.createArmy(msg.sender, params1[i], params2[i]);
			}
			
			// Creates items.
			// 아이템을 생산합니다.
			else if (orders[i] == ORDER_CREATE_ITEM) {
				itemManager.createItem(msg.sender, params1[i], params2[i]);
			}
			
			// Equips items.
			// 아이템을 장착합니다.
			else if (orders[i] == ORDER_ATTACH_ITEM) {
				armyManager.attachItem(msg.sender, params1[i], params2[i], params3[i]);
			}
			
			// Equips knight items.
			// 아이템을 장착합니다.
			else if (orders[i] == ORDER_ATTACH_KNIGHT_ITEM) {
				armyManager.attachKnightItem(msg.sender, params1[i], params2[i]);
			}
			
			// 단일 부대를 이동시킵니다.
			else if (orders[i] == ORDER_MOVE_ONE) {
				moveOne(params1[i], params2[i], params3[i], params4[i]);
			}
			
			// Armies move and attack.
			// 부대를 이동시키고, 해당 지역에 적이 있으면 공격합니다.
			else if (orders[i] == ORDER_MOVE_AND_ATTACK) {
				moveAndAttack(params1[i], params2[i], params3[i], params4[i], record);
			}
			
			// Ranged units attack given tiles.
			// 원거리 유닛으로 특정 지역을 공격합니다.
			else if (orders[i] == ORDER_RANGED_ATTACK) {
				rangedAttack(params1[i], params2[i], params3[i], params4[i], record);
			}
			
			else {
				revert();
			}
			
			// Adds a record.
			// 기록을 추가합니다.
			uint recordId = history.push(record).sub(1);
		
			// Emits the event.
			// 이벤트 발생
			emit NewRecord(msg.sender, recordId);
		}
	}
}
