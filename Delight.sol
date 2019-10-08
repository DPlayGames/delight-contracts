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
    
	uint constant private ORDER_BUILD				= 1;
	uint constant private ORDER_UPGRADE_HQ			= 2;
	uint constant private ORDER_CREATE_ARMY			= 3;
	uint constant private ORDER_CREATE_ITEM			= 4;
	uint constant private ORDER_ATTACH_ITEM			= 5;
	uint constant private ORDER_ATTACH_KNIGHT_ITEM	= 6;
	uint constant private ORDER_MOVE_ONE			= 7;
	uint constant private ORDER_MOVE_AND_ATTACK		= 8;
	uint constant private ORDER_RANGED_ATTACK		= 9;
	
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
			info = DelightInfoInterface(0xB5B11F194c6827ED98381a2e2703A8Ec69693B51);
			
			// knight item
			// 기사 아이템
			knightItem = DelightKnightItemInterface(0x0dA6E4186334D8d1af99C42F50255afe14553098);
			
			// managers
			// 관리자들
			buildingManager	= DelightBuildingManager(0xb28D186A960c1b1b8512D4e13a76e33A04F07De4);
			armyManager		= DelightArmyManager(0xB2DD2E6eC73e394366866FF2E9B7bb1893D986a8);
			itemManager		= DelightItemManager(0x034d5bE9b5368E947F40B8ab03f2c69C93c1Af67);
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
		
		// Big Bang!
		history.push(Record({
			order : 99,
			account : address(0),
			enemy : address(0),
			param1 : 0,
			param2 : 0,
			param3 : 0,
			param4 : 0,
			kill : 0,
			death : 0,
			isWin : false,
			time : now
		}));
	}
	
	Record[] private history;
	
	uint private lastAttackCol;
	uint private lastAttackRow;
	
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
		address enemy,
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
			record.enemy,
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
	function getTotalDamage(uint distance, uint[] memory armyIds, uint buildingBuffDamage) view public returns (uint totalDamage) {
		
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
							armyIds[UNIT_KNIGHT] != 0 && distance <= info.getUnitMovableDistance(UNIT_KNIGHT) ? KNIGHT_DEFAULT_BUFF_DAMAGE + knightItem.getItemBuffDamage(knightItemId) : 0
						)
						
					).add(
						
						// 이동 거리가 0일때만 병사 위치의 건물의 버프 데미지를 가져옵니다.
						distance == 0 ? buildingBuffDamage : 0
						
					).mul(armyUnitCount)
				);
			}
		}
		
		return totalDamage;
	}
	
	// Gets the total ranged damage.
	// 전체 원거리 데미지를 가져옵니다.
	function getTotalRangedDamage(uint distance, uint[] memory armyIds, uint buildingBuffDamage) view public returns (uint) {
		
		uint totalDamage = 0;
		
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
						buildingBuffDamage
						
					).mul(armyUnitCount)
				);
			}
		}
		
		return totalDamage;
	}
	
	// Army moves and attacks if there's enemy in the destination tile.
	// 부대를 이동시키고, 해당 지역에 적이 있으면 공격합니다.
	function moveAndAttack(uint fromCol, uint fromRow, uint toCol, uint toRow, Record memory record, uint distance, uint retryCount) private {
		
		// 위치가 달라야 합니다.
		require(fromCol != toCol || fromRow != toRow);
		
		// 범위 체크
		require(fromCol < COL_RANGE && fromRow < ROW_RANGE);
		require(toCol < COL_RANGE && toRow < ROW_RANGE);
		
		// 부대의 소유주인지 확인합니다.
		require(msg.sender == armyManager.getPositionOwner(fromCol, fromRow));
		
		// 아무도 없는 곳이거나 아군이면 부대를 이동시킵니다.
		if (record.enemy == address(0) || record.enemy == msg.sender) {
			armyManager.moveArmy(fromCol, fromRow, toCol, toRow);
			
			// 적군의 건물이 존재하면 파괴합니다.
			if (buildingManager.getPositionBuildingId(toCol, toRow) != 0 && buildingManager.getPositionBuildingOwner(toCol, toRow) != msg.sender) {
				armyManager.destroyBuilding(history.length, toCol, toRow);
				armyManager.win(history.length, msg.sender);
				record.isWin = true;
			}
		}
		
		// If there's a hostile army in the destination, attack.
		// 적군이면 전투를 개시합니다.
		else {
			
			// 마지막 공격 위치 저장
			lastAttackCol = toCol;
			lastAttackRow = toRow;
			
			uint totalDamage = getTotalDamage(distance, armyManager.getPositionArmyIds(fromCol, fromRow), buildingManager.getBuildingBuffDamage(fromCol, fromRow));
			uint totalEnemyDamage = getTotalDamage(0, armyManager.getPositionArmyIds(toCol, toRow), buildingManager.getBuildingBuffDamage(toCol, toRow));
			
			uint kill = armyManager.attack(history.length, totalDamage, 0, toCol, toRow);
			uint death = armyManager.attack(history.length, totalEnemyDamage, distance, fromCol, fromRow);
			
			record.kill = record.kill.add(kill);
			record.death = record.death.add(death);
			
			// 아무 변화가 없는 경우에는 공격자가 유리합니다. (상대의 남아있는 병력을 모두 제거합니다.)
			if (kill == 0 && death == 0) {
				armyManager.win(history.length, msg.sender);
				record.isWin = true;
			}
			
			// 한번의 공격으로 전투가 끝나지 않았을 때
			else if (armyManager.getTotalUnitCount(distance, fromCol, fromRow) > 0 && armyManager.getTotalUnitCount(0, toCol, toRow) > 0) {
				
				// 재시도 횟수가 5번을 초과한 경우, 공격자가 승리합니다.
				if (retryCount == 5) {
					armyManager.win(history.length, msg.sender);
					record.isWin = true;
				}
				
				// 재공격
				else {
					moveAndAttack(fromCol, fromRow, toCol, toRow, record, distance, retryCount + 1);
				}
			}
			
			// If the enemy building is captured, move the soldiers.
			// 적진을 점령했다면, 병사들을 이동시킵니다.
			else if (armyManager.getPositionOwner(toCol, toRow) == address(0)) {
				armyManager.moveArmy(fromCol, fromRow, toCol, toRow);
				armyManager.destroyBuilding(history.length, toCol, toRow);
				armyManager.win(history.length, msg.sender);
				record.isWin = true;
			}
			
			// enemy won
			// 상대가 승리했습니다.
			else {
				armyManager.win(history.length, record.enemy);
			}
		}
	}
	
	// 단일 부대를 이동시킵니다.
	function moveOne(uint armyId, uint unitCount, uint toCol, uint toRow) private {
		
		// 범위 체크
		require(toCol < COL_RANGE && toRow < ROW_RANGE);
		
		// 적군의 건물이 존재하면 이동이 불가능합니다.
		require(buildingManager.getPositionBuildingId(toCol, toRow) == 0 || buildingManager.getPositionBuildingOwner(toCol, toRow) == msg.sender);
		
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
		
		armyManager.moveArmyOne(armyManager.getTotalUnitCount(0, toCol, toRow), armyId, unitCount, toCol, toRow);
	}
	
	// Range unit attacks a given tile.
	// 원거리 유닛으로 특정 지역을 공격합니다.
	function rangedAttack(uint fromCol, uint fromRow, uint toCol, uint toRow, Record memory record) private {
		
		// 위치가 달라야 합니다.
		require(fromCol != toCol || fromRow != toRow);
		
		// 범위 체크
		require(fromCol < COL_RANGE && fromRow < ROW_RANGE);
		require(toCol < COL_RANGE && toRow < ROW_RANGE);
		
		// 부대의 소유주인지 확인합니다.
		require(msg.sender == armyManager.getPositionOwner(fromCol, fromRow));
		
		address enemy = armyManager.getPositionOwner(toCol, toRow);
		
		// Cannot attack friendly force.
		// 아군은 공격할 수 없습니다.
		require(enemy != msg.sender);
		
		// Calculates the distance.
		// 거리 계산
		uint distance = (fromCol < toCol ? toCol - fromCol : fromCol - toCol) + (fromRow < toRow ? toRow - fromRow : fromRow - toRow);
		
		uint totalDamage = getTotalRangedDamage(distance, armyManager.getPositionArmyIds(fromCol, fromRow), buildingManager.getBuildingBuffDamage(fromCol, fromRow));
		uint totalEnemyDamage = getTotalRangedDamage(distance, armyManager.getPositionArmyIds(toCol, toRow), buildingManager.getBuildingBuffDamage(toCol, toRow));
		
		// 원거리 공격합니다.
		record.enemy = enemy;
		record.kill = armyManager.attack(0, totalDamage, 0, toCol, toRow);
		record.death = armyManager.attack(0, totalEnemyDamage, 0, fromCol, fromRow);
	}
	
	// Executes the order que.
	// 명령 큐를 실행합니다.
	function runOrderQueue(uint[] calldata orders, uint[] calldata params1, uint[] calldata params2, uint[] calldata params3, uint[] calldata params4) external {
		
		require(orders.length > 0);
		
		for (uint i = 0; i < orders.length; i += 1) {
			
			Record memory record = Record({
				order : orders[i],
				account : msg.sender,
				enemy : address(0),
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
				
				// 거리 계산 (재전투 시 중복 계산을 방지하기 위해 여기서 계산합니다.)
				uint distance = (params1[i] < params3[i] ? params3[i] - params1[i] : params1[i] - params3[i]) + (params2[i] < params4[i] ? params4[i] - params2[i] : params2[i] - params4[i]);
				
				record.enemy = armyManager.getPositionOwner(params3[i], params4[i]);
				
				moveAndAttack(params1[i], params2[i], params3[i], params4[i], record, distance, 0);
			}
			
			// Ranged units attack given tiles.
			// 원거리 유닛으로 특정 지역을 공격합니다.
			else if (orders[i] == ORDER_RANGED_ATTACK) {
				
				// 이미 공격 명령이 내려진 부대라면 거부합니다.
				for (uint j = 0; j < i; j += 1) {
					if (params1[j] == params1[i] && params2[j] == params2[i]) {
						revert();
					}
				}
				
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
	
	// 마지막 공격 위치를 가져옵니다.
	function getLastAttackPosition() view external returns (uint col, uint row) {
		return (
			lastAttackCol,
			lastAttackRow
		);
	}
}
