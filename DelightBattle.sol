pragma solidity ^0.5.9;

import "./DelightWorldInterface.sol";
import "./DelightSub.sol";
import "./Util/SafeMath.sol";

// 전투 관련 처리
contract DelightBattle is DelightSub {
	using SafeMath for uint;
	
	event Move				(address indexed owner, uint fromCol, uint fromRow, uint toCol, uint toRow);
    event MoveArmy			(address indexed owner, uint fromArmyId, uint toArmyId, uint unitCount);
    
    event Win				(address indexed owner, address indexed enemy, uint fromCol, uint fromRow, uint toCol, uint toRow, uint wood, uint stone, uint iron, uint ducat);
    event Lose				(address indexed owner, address indexed enemy, uint fromCol, uint fromRow, uint toCol, uint toRow, uint wood, uint stone, uint iron, uint ducat);
    event RangedAttack		(address indexed owner, address indexed enemy, uint fromCol, uint fromRow, uint toCol, uint toRow, uint wood, uint stone, uint iron, uint ducat, uint enemyWood, uint enemyStone, uint enemyIron, uint enemyDucat);
    event DeadUnits			(address indexed owner, uint armyId, uint unitCount);
	
	// 기사의 기본 버프
	uint constant internal KNIGHT_DEFAULT_BUFF_HP = 10;
	uint constant internal KNIGHT_DEFAULT_BUFF_DAMAGE = 5;
	
	DelightWorldInterface private delightWorld;
	
	constructor() DelightSub() public {
		
		// DPlay History 스마트 계약을 불러옵니다.
		if (network == Network.Mainnet) {
			//TODO
		} else if (network == Network.Kovan) {
			//TODO
			delightWorld = DelightWorldInterface(0x0);
		} else if (network == Network.Ropsten) {
			//TODO
		} else if (network == Network.Rinkeby) {
			//TODO
		} else {
			revert();
		}
	}
	
	// 부대를 이동시키고, 해당 지역에 적이 있으면 공격합니다.
	function moveAndAttack(
		address owner,
		uint fromCol, uint fromRow,
		uint toCol, uint toRow
	) onlyDelight checkRange(fromCol, fromRow) checkRange(toCol, toRow) external {
		
		// 부대의 소유주를 확인합니다.
		require(delightWorld.getArmyOwnerByPosition(fromCol, fromRow) == owner);
		
		// 거리 계산
		uint distance = (fromCol < toCol ? toCol - fromCol : fromCol - toCol) + (fromRow < toRow ? toRow - fromRow : fromRow - toRow);
		
		// 전리품
		Material memory rewardMaterial = Material({
			wood : 0,
			stone : 0,
			iron : 0,
			ducat : 0
		});
		
		address targetArmyOwner = delightWorld.getArmyOwnerByPosition(toCol, toRow);
		
		uint[] memory armyIds = delightWorld.getArmyIdsByPosition(fromCol, fromRow);
		uint[] memory targetArmyIds = delightWorld.getArmyIdsByPosition(toCol, toRow);
		
		// 아군이 위치한 곳이면 부대를 합병합니다.
		if (targetArmyOwner == owner) {
			/*
			uint totalUnitCount = 0;
			for (uint i = 0; i < targetArmyIds.length; i += 1) {
				
				(
					,
					uint targetArmyUnitCount,
					,
					,
					,
					,
					
				) = delightWorld.getArmyInfo(targetArmyIds[i]);
				
				totalUnitCount = totalUnitCount.add(targetArmyUnitCount);
			}
			
			for (uint i = 0; i < UNIT_KIND_COUNT; i += 1) {
				
				(
					uint armyUnitKind,
					uint armyUnitCount,
					,
					,
					,
					,
					
				) = delightWorld.getArmyInfo(armyIds[i]);
				
				if (
				// 유닛의 개수가 0개 이상이어야 합니다.
				armyUnitCount > 0 &&
				
				// 이동이 가능한 거리인지 확인합니다.
				distance <= units[armyUnitKind].movableDistance) {
					
					(
						,
						uint targetArmyUnitCount,
						,
						,
						,
						,
						
					) = delightWorld.getArmyInfo(targetArmyIds[i]);
					
					if (totalUnitCount.add(armyUnitCount) >= MAX_POSITION_UNIT_COUNT) {
						
						// 이동할 유닛의 개수가 0개 이상이어야 합니다.
						if (MAX_POSITION_UNIT_COUNT.sub(totalUnitCount) > 0) {
							
							// 비어있는 곳이면 새 부대를 생성합니다.
							if (targetArmyUnitCount == 0) {
								
								targetArmyIds[armyUnitKind] = delightWorld.newArmy(
									armyUnitKind,
									MAX_POSITION_UNIT_COUNT.sub(totalUnitCount),
									toCol,
									toRow,
									owner
								);
								
								// 상세 기록을 저장합니다.
								delightHistory.addTargetArmyRecordDetail(
									delightHistory.getRecordCount(),
									owner,
									armyIds[i],
									targetArmyIds[i],
									armyUnitKind,
									MAX_POSITION_UNIT_COUNT.sub(totalUnitCount)
								);
								
								// 이벤트 발생
								emit MoveArmy(owner, armyIds[i], targetArmyIds[i], MAX_POSITION_UNIT_COUNT.sub(totalUnitCount));
							}
							
							// 비어있지 않으면 합병합니다.
							else {
								
								targetArmyUnitCount = targetArmyUnitCount.add(MAX_POSITION_UNIT_COUNT.sub(totalUnitCount));
								armyUnitCount = armyUnitCount.sub(MAX_POSITION_UNIT_COUNT.sub(totalUnitCount));
								
								// 상세 기록을 저장합니다.
								delightHistory.addTargetArmyRecordDetail(
									delightHistory.getRecordCount(),
									owner,
									armyIds[i],
									targetArmyIds[i],
									armyUnitKind,
									MAX_POSITION_UNIT_COUNT.sub(totalUnitCount)
								);
								
								// 이벤트 발생
								emit MoveArmy(owner, armyIds[i], targetArmyIds[i], MAX_POSITION_UNIT_COUNT.sub(totalUnitCount));
							}
						}
					}
					
					else {
						
						// 비어있는 곳이면 이전합니다.
						if (targetArmyUnitCount == 0) {
							
							targetArmyIds[i] = armyIds[i];
							
							// 상세 기록을 저장합니다.
							delightHistory.addTargetArmyRecordDetail(
								delightHistory.getRecordCount(),
								owner,
								armyIds[i],
								targetArmyIds[i],
								armyUnitKind,
								armyUnitCount
							);
							
							// 이벤트 발생
							emit MoveArmy(owner, armyIds[i], targetArmyIds[i], armyUnitCount);
							
							delete armyIds[i];
						}
						
						// 비어있지 않으면 합병합니다.
						else {
							
							targetArmyUnitCount = targetArmyUnitCount.add(armyUnitCount);
							
							// 상세 기록을 저장합니다.
							delightHistory.addTargetArmyRecordDetail(
								delightHistory.getRecordCount(),
								owner,
								armyIds[i],
								targetArmyIds[i],
								armyUnitKind,
								armyUnitCount
							);
							
							// 이벤트 발생
							emit MoveArmy(owner, armyIds[i], targetArmyIds[i], armyUnitCount);
							
							delightWorld.removeArmy(armyIds[i]);
						}
					}
				}
			}
			
			// 기록을 저장합니다.
			delightHistory.recordMoveArmy(owner, fromCol, fromRow, toCol, toRow);
			
			// 이벤트 발생
			emit Move(owner, fromCol, fromRow, toCol, toRow);
			*/
		}
		
		// 적군이 위치한 곳이면 공격합니다.
		else {
			
			uint totalDamage = 0;
			uint totalEnemyDamage = 0;
			
			// 총 공격력을 계산합니다.
			for (uint i = 0; i < UNIT_KIND_COUNT; i += 1) {
				
				(
					uint armyUnitKind,
					uint armyUnitCount,
					uint armyKnightItemId,
					,
					,
					,
					
				) = delightWorld.getArmyInfo(armyIds[i]);
				
				(
					,
					,
					uint knightItemId,
					,
					,
					,
					
				) = delightWorld.getArmyInfo(armyIds[UNIT_KNIGHT]);
				
				if (
				// 유닛의 개수가 0개 이상이어야 합니다.
				armyUnitCount > 0 &&
				
				// 이동이 가능한 거리인지 확인합니다.
				distance <= units[armyUnitKind].movableDistance) {
					
					// 아군의 공격력 추가
					totalDamage = totalDamage.add(
						units[armyUnitKind].damage.add(
							
							// 기사인 경우 기사 아이템의 공격력을 추가합니다.
							i == UNIT_KNIGHT ? knightItem.getItemDamage(armyKnightItemId) : (
								
								// 기사가 아닌 경우 기사의 버프 데미지를 추가합니다.
								0//armyIds[UNIT_KNIGHT] != 0 == true ? KNIGHT_DEFAULT_BUFF_DAMAGE + knightItem.getItemBuffDamage(knightItemId) : 0
							)
							
						).mul(armyUnitCount)
					);
				}
				
				(
					uint enemyArmyUnitKind,
					uint enemyArmyUnitCount,
					uint enemyArmyKnightItemId,
					,
					,
					,
					
				) = delightWorld.getArmyInfo(targetArmyIds[i]);
				
				(
					,
					,
					uint targetKnightItemId,
					,
					,
					,
					
				) = delightWorld.getArmyInfo(targetArmyIds[UNIT_KNIGHT]);
				
				// 유닛의 개수가 0개 이상이어야 합니다.
				if (enemyArmyUnitCount > 0) {
					
					// 적군의 공격력 추가
					totalEnemyDamage = totalEnemyDamage.add(
						units[enemyArmyUnitKind].damage.add(
							
							// 기사인 경우 기사 아이템의 공격력을 추가합니다.
							i == UNIT_KNIGHT ? knightItem.getItemDamage(enemyArmyKnightItemId) : (
								
								// 기사가 아닌 경우 기사의 버프 데미지를 추가합니다.
								0//targetArmyIds[UNIT_KNIGHT] != 0 == true ? KNIGHT_DEFAULT_BUFF_DAMAGE + knightItem.getItemBuffDamage(targetKnightItemId) : 0
							)
							
						).mul(enemyArmyUnitCount)
					);
				}
			}
			
			// 전투를 개시합니다.
			/*
			for (uint i = 0; i < UNIT_KIND_COUNT; i += 1) {
				
				(
					uint armyUnitKind,
					uint armyUnitCount,
					uint armyKnightItemId,
					uint armyCol,
					uint armyRow,
					,
					uint armyCreateTime
				) = delightWorld.getArmyInfo(armyIds[i]);
				
				(
					,
					,
					uint knightItemId,
					,
					,
					,
					
				) = delightWorld.getArmyInfo(armyIds[UNIT_KNIGHT]);
				
				if (
				// 유닛의 개수가 0개 이상이어야 합니다.
				armyUnitCount > 0 &&
				
				// 이동이 가능한 거리인지 확인합니다.
				distance <= units[armyUnitKind].movableDistance) {
					
					// 아군의 체력을 계산합니다.
					uint armyHP = units[armyUnitKind].hp.add(
						
						// 기사인 경우 기사 아이템의 HP를 추가합니다.
						i == UNIT_KNIGHT ? knightItem.getItemHP(armyKnightItemId) : (
							
							// 기사가 아닌 경우 기사의 버프 HP를 추가합니다.
							0//armyIds[UNIT_KNIGHT] != 0 == true ? KNIGHT_DEFAULT_BUFF_HP + knightItem.getItemBuffHP(knightItemId) : 0
						)
						
					).mul(armyUnitCount);
					
					armyHP = armyHP <= totalEnemyDamage ? 0 : armyHP.sub(totalEnemyDamage);
					
					// 전투 결과를 계산합니다.
					//uint remainUnitCount = armyHP.add(armyHP % units[armyUnitKind].hp).div(units[armyUnitKind].hp);
					uint deadUnitCount = 0;//uint deadUnitCount = armyUnitCount.sub(remainUnitCount);
					
					// 적의 총 공격력을 낮춥니다.
					totalEnemyDamage = totalEnemyDamage <= deadUnitCount.mul(units[armyUnitKind].hp) ? 0 : totalEnemyDamage.sub(deadUnitCount.mul(units[armyUnitKind].hp));
					
					// 전리품을 계산합니다.
					Material memory unitMaterial = unitMaterials[armyUnitKind];
					rewardMaterial.wood = rewardMaterial.wood.add(unitMaterial.wood.mul(deadUnitCount));
					rewardMaterial.stone = rewardMaterial.wood.add(unitMaterial.stone.mul(deadUnitCount));
					rewardMaterial.iron = rewardMaterial.wood.add(unitMaterial.iron.mul(deadUnitCount));
					rewardMaterial.ducat = rewardMaterial.wood.add(unitMaterial.ducat.mul(deadUnitCount));
					
					// 남은 병사 숫자를 저장합니다.
					//delightWorld.updateArmy(armyIds[i], remainUnitCount);
					
					// 상세 기록을 저장합니다.
					delightHistory.addArmyRecordDetail(
						delightHistory.getRecordCount(),
						owner,
						armyIds[i],
						armyUnitKind,
						deadUnitCount
					);
					
					// 이벤트 발생
					emit DeadUnits(owner, armyIds[i], deadUnitCount);
				}
				
				(
					uint enemyArmyUnitKind,
					uint enemyArmyUnitCount,
					uint enemyArmyKnightItemId,
					uint enemyArmyCol,
					uint enemyArmyRow,
					,
					uint enemyArmyCreateTime
				) = delightWorld.getArmyInfo(targetArmyIds[i]);
				
				(
					,
					,
					uint targetKnightItemId,
					,
					,
					,
					
				) = delightWorld.getArmyInfo(targetArmyIds[UNIT_KNIGHT]);
				
				// 유닛의 개수가 0개 이상이어야 합니다.
				if (enemyArmyUnitCount > 0) {
					
					// 적군의 체력을 계산합니다.
					uint ememyArmyHP = units[enemyArmyUnitKind].hp.add(
						
						// 기사인 경우 기사 아이템의 HP를 추가합니다.
						i == UNIT_KNIGHT ? knightItem.getItemHP(enemyArmyKnightItemId) : (
							
							// 기사가 아닌 경우 기사의 버프 HP를 추가합니다.
							targetArmyIds[UNIT_KNIGHT] != 0 == true ? KNIGHT_DEFAULT_BUFF_HP + knightItem.getItemBuffHP(targetKnightItemId) : 0
						)
						
					).mul(enemyArmyUnitCount);
					
					ememyArmyHP = ememyArmyHP <= totalDamage ? 0 : ememyArmyHP.sub(totalDamage);
					
					// 전투 결과를 계산합니다.
					uint remainEnemyUnitCount = ememyArmyHP.add(ememyArmyHP % units[enemyArmyUnitKind].hp).div(units[enemyArmyUnitKind].hp);
					uint deadEnemyUnitCount = enemyArmyUnitCount.sub(remainEnemyUnitCount);
					
					// 아군의 총 공격력을 낮춥니다.
					totalDamage = totalDamage <= deadEnemyUnitCount.mul(units[enemyArmyUnitKind].hp) ? 0 : totalDamage.sub(deadEnemyUnitCount.mul(units[enemyArmyUnitKind].hp));
					
					// 전리품을 계산합니다.
					rewardMaterial.wood = rewardMaterial.wood.add(unitMaterials[enemyArmyUnitKind].wood.mul(deadEnemyUnitCount));
					rewardMaterial.stone = rewardMaterial.wood.add(unitMaterials[enemyArmyUnitKind].stone.mul(deadEnemyUnitCount));
					rewardMaterial.iron = rewardMaterial.wood.add(unitMaterials[enemyArmyUnitKind].iron.mul(deadEnemyUnitCount));
					rewardMaterial.ducat = rewardMaterial.wood.add(unitMaterials[enemyArmyUnitKind].ducat.mul(deadEnemyUnitCount));
					
					// 남은 병사 숫자를 저장합니다.
					delightWorld.updateArmy(targetArmyIds[i], remainEnemyUnitCount);
					
					// 상세 기록을 저장합니다.
					delightHistory.addArmyRecordDetail(
						delightHistory.getRecordCount(),
						targetArmyOwner,
						targetArmyIds[i],
						enemyArmyUnitKind,
						deadEnemyUnitCount
					);
					
					// 이벤트 발생
					emit DeadUnits(targetArmyOwner, targetArmyIds[i], deadEnemyUnitCount);
				}
			}
			*/
			
			// 승리
			if (totalDamage >= totalEnemyDamage) {
				
				// 승리하면 병력을 이동합니다.
				for (uint i = 0; i < UNIT_KIND_COUNT; i += 1) {
					
					(
						uint armyUnitKind,
						uint armyUnitCount,
						,
						,
						,
						,
						
					) = delightWorld.getArmyInfo(armyIds[i]);
					
					if (
					// 유닛의 개수가 0개 이상이어야 합니다.
					armyUnitCount > 0 &&
					
					// 이동이 가능한 거리인지 확인합니다.
					distance <= units[armyUnitKind].movableDistance) {
						
						targetArmyIds[i] = armyIds[i];
						
						delete armyIds[i];
					}
				}
				
				// 만약 건물이 존재하면, 건물을 파괴합니다.
				/*if (positionToBuildingId[toCol][toRow] != 0) {
					
					uint buildingKind = buildings[positionToBuildingId[toCol][toRow]].kind;
					
					// 전리품을 추가합니다.
					Material memory buildingMaterial = buildingMaterials[buildingKind];
					rewardMaterial.wood = rewardMaterial.wood.add(buildingMaterial.wood);
					rewardMaterial.stone = rewardMaterial.wood.add(buildingMaterial.stone);
					rewardMaterial.iron = rewardMaterial.wood.add(buildingMaterial.iron);
					rewardMaterial.ducat = rewardMaterial.wood.add(buildingMaterial.ducat);
					
					// 본부인 경우, 본부 목록에서 제거합니다.
					if (buildingKind == BUILDING_HQ) {
						
						uint[] storage hqIds = ownerToHQIds[targetArmyOwner];
						
						for (uint i = hqIds.length - 1; i > 0; i -= 1) {
							
							if (hqIds[i - 1] == positionToBuildingId[toCol][toRow]) {
								hqIds[i - 1] = hqIds[i];
								break;
							} else {
								hqIds[i - 1] = hqIds[i];
							}
						}
						
						hqIds.length -= 1;
					}
					
					// 건물을 파괴합니다.
					delete buildings[positionToBuildingId[toCol][toRow]];
					delete positionToBuildingId[toCol][toRow];
					
					// 상세 기록을 저장합니다.
					delightHistory.addBuildingRecordDetail(
						delightHistory.getRecordCount(),
						targetArmyOwner,
						positionToBuildingId[toCol][toRow],
						buildingKind
					);
					
					// 이벤트 발생
					emit DestroyBuilding(targetArmyOwner, positionToBuildingId[toCol][toRow], buildingKind, toCol, toRow);
				}*/
				
				// 전리품을 취득합니다.
				wood.transferFrom(address(this), owner, rewardMaterial.wood);
				stone.transferFrom(address(this), owner, rewardMaterial.stone);
				iron.transferFrom(address(this), owner, rewardMaterial.iron);
				ducat.transferFrom(address(this), owner, rewardMaterial.ducat);
				
				// 기록을 저장합니다.
				delightHistory.recordWin(owner, targetArmyOwner, fromCol, fromRow, toCol, toRow, rewardMaterial.wood, rewardMaterial.stone, rewardMaterial.iron, rewardMaterial.ducat);
				
				// 이벤트 발생
				emit Win(owner, targetArmyOwner, fromCol, fromRow, toCol, toRow, rewardMaterial.wood, rewardMaterial.stone, rewardMaterial.iron, rewardMaterial.ducat);
			}
			
			// 패배
			else {
				
				// 패배하면 상대방이 전리품을 취득합니다.
				wood.transferFrom(address(this), targetArmyOwner, rewardMaterial.wood);
				stone.transferFrom(address(this), targetArmyOwner, rewardMaterial.stone);
				iron.transferFrom(address(this), targetArmyOwner, rewardMaterial.iron);
				ducat.transferFrom(address(this), targetArmyOwner, rewardMaterial.ducat);
				
				// 기록을 저장합니다.
				delightHistory.recordLose(owner, targetArmyOwner, fromCol, fromRow, toCol, toRow, rewardMaterial.wood, rewardMaterial.stone, rewardMaterial.iron, rewardMaterial.ducat);
				
				// 이벤트 발생
				emit Lose(owner, targetArmyOwner, fromCol, fromRow, toCol, toRow, rewardMaterial.wood, rewardMaterial.stone, rewardMaterial.iron, rewardMaterial.ducat);
			}
		}
	}
	
	/*
	// 원거리 유닛으로 특정 지역을 공격합니다.
	function rangedAttack(
		address owner,
		uint fromCol, uint fromRow,
		uint toCol, uint toRow
	) onlyDelight checkRange(fromCol, fromRow) checkRange(toCol, toRow) external {
		
		// 부대의 소유주를 확인합니다.
		require(getArmyOwnerByPosition(fromCol, fromRow) == owner);
		
		address targetArmyOwner = getArmyOwnerByPosition(toCol, toRow);
		
		// 아군을 공격할 수 없습니다.
		require(targetArmyOwner != owner);
		
		// 거리 계산
		uint distance = (fromCol < toCol ? toCol - fromCol : fromCol - toCol) + (fromRow < toRow ? toRow - fromRow : fromRow - toRow);
		
		uint[] storage armyIds = positionToArmyIds[fromCol][fromRow];
		uint[] storage targetArmyIds = positionToArmyIds[toCol][toRow];
		
		uint totalDamage = 0;
		uint totalEnemyDamage = 0;
		
		// 돌려받을 자원
		Material memory returnMaterial = Material({
			wood : 0,
			stone : 0,
			iron : 0,
			ducat : 0
		});
		
		// 적이 돌려받을 자원
		Material memory enemyReturnMaterial = Material({
			wood : 0,
			stone : 0,
			iron : 0,
			ducat : 0
		});
		
		// 총 공격력을 계산합니다.
		for (uint i = 0; i < UNIT_KIND_COUNT; i += 1) {
			
			Army memory army = armies[armyIds[i]];
			
			if (
			// 유닛의 개수가 0개 이상이어야 합니다.
			armyUnitCount > 0 &&
			
			// 공격이 가능한 거리인지 확인합니다.
			distance <= units[armyUnitKind].attackableDistance) {
				
				// 아군의 공격력 추가
				totalDamage = totalDamage.add(
					units[armyUnitKind].damage.add(
						
						// 기사인 경우 기사 아이템의 공격력을 추가합니다.
						i == UNIT_KNIGHT ? knightItem.getItemDamage(army.knightItemId) : (
							
							// 기사가 아닌 경우 기사의 버프 데미지를 추가합니다.
							armyIds[UNIT_KNIGHT] != 0 == true ? KNIGHT_DEFAULT_BUFF_DAMAGE + knightItem.getItemBuffDamage(armies[armyIds[UNIT_KNIGHT]].knightItemId) : 0
						)
						
					).mul(armyUnitCount)
				);
			}
			
			Army memory enemyArmy = armies[targetArmyIds[i]];
			
			if (
			// 유닛의 개수가 0개 이상이어야 합니다.
			enemyArmyUnitCount > 0 &&
			
			// 공격이 가능한 거리인지 확인합니다.
			distance <= units[enemyArmyUnitKind].attackableDistance) {
				
				// 적군의 공격력 추가
				totalEnemyDamage = totalEnemyDamage.add(
					units[enemyArmyUnitKind].damage.add(
						
						// 기사인 경우 기사 아이템의 공격력을 추가합니다.
						i == UNIT_KNIGHT ? knightItem.getItemDamage(enemyArmy.knightItemId) : (
							
							// 기사가 아닌 경우 기사의 버프 데미지를 추가합니다.
							targetArmyIds[UNIT_KNIGHT] != 0 == true ? KNIGHT_DEFAULT_BUFF_DAMAGE + knightItem.getItemBuffDamage(armies[targetArmyIds[UNIT_KNIGHT]].knightItemId) : 0
						)
						
					).mul(enemyArmyUnitCount)
				);
			}
		}
		
		// 전투를 개시합니다.
		for (uint i = 0; i < UNIT_KIND_COUNT; i += 1) {
			
			// 적군이 아군을 공격합니다.
			Army storage army = armies[armyIds[i]];
			
			// 유닛의 개수가 0개 이상이어야 합니다.
			if (armyUnitCount > 0) {
				
				// 아군의 체력을 계산합니다.
				uint armyHP = units[armyUnitKind].hp.add(
					
					// 기사인 경우 기사 아이템의 HP를 추가합니다.
					i == UNIT_KNIGHT ? knightItem.getItemHP(army.knightItemId) : (
						
						// 기사가 아닌 경우 기사의 버프 HP를 추가합니다.
						armyIds[UNIT_KNIGHT] != 0 == true ? KNIGHT_DEFAULT_BUFF_HP + knightItem.getItemBuffHP(armies[armyIds[UNIT_KNIGHT]].knightItemId) : 0
					)
					
				).mul(armyUnitCount);
				
				armyHP = armyHP <= totalEnemyDamage ? 0 : armyHP.sub(totalEnemyDamage);
				
				// 전투 결과를 계산합니다.
				uint remainUnitCount = armyHP.add(armyHP % units[armyUnitKind].hp).div(units[armyUnitKind].hp);
				uint deadUnitCount = armyUnitCount.sub(remainUnitCount);
				
				// 적의 총 공격력을 낮춥니다.
				totalEnemyDamage = totalEnemyDamage <= deadUnitCount.mul(units[armyUnitKind].hp) ? 0 : totalEnemyDamage.sub(deadUnitCount.mul(units[armyUnitKind].hp));
				
				// 돌려받을 자원을 계산합니다.
				returnMaterial.wood = returnMaterial.wood.add(unitMaterials[armyUnitKind].wood.mul(deadUnitCount));
				returnMaterial.stone = returnMaterial.wood.add(unitMaterials[armyUnitKind].stone.mul(deadUnitCount));
				returnMaterial.iron = returnMaterial.wood.add(unitMaterials[armyUnitKind].iron.mul(deadUnitCount));
				returnMaterial.ducat = returnMaterial.wood.add(unitMaterials[armyUnitKind].ducat.mul(deadUnitCount));
				
				// 남은 병사 숫자를 저장합니다.
				armyUnitCount = remainUnitCount;
				if (armyUnitCount == 0) {
					army.owner = address(0x0);
				}
				
				// 상세 기록을 저장합니다.
				delightHistory.addArmyRecordDetail(
					delightHistory.getRecordCount(),
					owner,
					armyIds[i],
					armyUnitKind,
					deadUnitCount
				);
				
				// 이벤트 발생
				emit DeadUnits(owner, armyIds[i], deadUnitCount);
			}
			
			// 아군이 적군을 공격합니다.
			
			// 유닛의 개수가 0개 이상이어야 합니다.
			if (armies[targetArmyIds[i]].unitCount > 0) {
				
				// 적군의 체력을 계산합니다.
				uint ememyArmyHP = units[armies[targetArmyIds[i]].unitKind].hp.add(
					
					// 기사인 경우 기사 아이템의 HP를 추가합니다.
					i == UNIT_KNIGHT ? knightItem.getItemHP(armies[targetArmyIds[i]].knightItemId) : (
						
						// 기사가 아닌 경우 기사의 버프 HP를 추가합니다.
						targetArmyIds[UNIT_KNIGHT] != 0 == true ? KNIGHT_DEFAULT_BUFF_HP + knightItem.getItemBuffHP(armies[targetArmyIds[UNIT_KNIGHT]].knightItemId) : 0
					)
					
				).mul(armies[targetArmyIds[i]].unitCount);
				
				ememyArmyHP = ememyArmyHP <= totalDamage ? 0 : ememyArmyHP.sub(totalDamage);
				
				// 전투 결과를 계산합니다.
				uint remainEnemyUnitCount = ememyArmyHP.add(ememyArmyHP % units[armies[targetArmyIds[i]].unitKind].hp).div(units[armies[targetArmyIds[i]].unitKind].hp);
				uint deadEnemyUnitCount = armies[targetArmyIds[i]].unitCount.sub(remainEnemyUnitCount);
				
				// 아군의 총 공격력을 낮춥니다.
				totalDamage = totalDamage <= deadEnemyUnitCount.mul(units[armies[targetArmyIds[i]].unitKind].hp) ? 0 : totalDamage.sub(deadEnemyUnitCount.mul(units[armies[targetArmyIds[i]].unitKind].hp));
				
				// 돌려받을 자원을 계산합니다.
				enemyReturnMaterial.wood = enemyReturnMaterial.wood.add(unitMaterials[armies[targetArmyIds[i]].unitKind].wood.mul(deadEnemyUnitCount));
				enemyReturnMaterial.stone = enemyReturnMaterial.wood.add(unitMaterials[armies[targetArmyIds[i]].unitKind].stone.mul(deadEnemyUnitCount));
				enemyReturnMaterial.iron = enemyReturnMaterial.wood.add(unitMaterials[armies[targetArmyIds[i]].unitKind].iron.mul(deadEnemyUnitCount));
				enemyReturnMaterial.ducat = enemyReturnMaterial.wood.add(unitMaterials[armies[targetArmyIds[i]].unitKind].ducat.mul(deadEnemyUnitCount));
				
				// 남은 병사 숫자를 저장합니다.
				armies[targetArmyIds[i]].unitCount = remainEnemyUnitCount;
				if (armies[targetArmyIds[i]].unitCount == 0) {
					armies[targetArmyIds[i]].owner = address(0x0);
				}
				
				// 상세 기록을 저장합니다.
				delightHistory.addArmyRecordDetail(
					delightHistory.getRecordCount(),
					targetArmyOwner,
					targetArmyIds[i],
					armies[targetArmyIds[i]].unitKind,
					deadEnemyUnitCount
				);
				
				// 이벤트 발생
				emit DeadUnits(targetArmyOwner, targetArmyIds[i], deadEnemyUnitCount);
			}
		}
		
		// 자원을 돌려받습니다.
		wood.transferFrom(address(this), owner, returnMaterial.wood);
		stone.transferFrom(address(this), owner, returnMaterial.stone);
		iron.transferFrom(address(this), owner, returnMaterial.iron);
		ducat.transferFrom(address(this), owner, returnMaterial.ducat);
		
		wood.transferFrom(address(this), targetArmyOwner, enemyReturnMaterial.wood);
		stone.transferFrom(address(this), targetArmyOwner, enemyReturnMaterial.stone);
		iron.transferFrom(address(this), targetArmyOwner, enemyReturnMaterial.iron);
		ducat.transferFrom(address(this), targetArmyOwner, enemyReturnMaterial.ducat);
		
		// 상세 기록을 저장합니다.
		delightHistory.addEnemyResourceRecordDetail(
			delightHistory.getRecordCount(),
			targetArmyOwner,
			enemyReturnMaterial.wood, enemyReturnMaterial.stone, enemyReturnMaterial.iron, enemyReturnMaterial.ducat
		);
		
		// 기록을 저장합니다.
		delightHistory.recordRangedAttack(owner, targetArmyOwner, fromCol, fromRow, toCol, toRow, returnMaterial.wood, returnMaterial.stone, returnMaterial.iron, returnMaterial.ducat);
		
		// 이벤트 발생
		emit RangedAttack(owner, targetArmyOwner, fromCol, fromRow, toCol, toRow, returnMaterial.wood, returnMaterial.stone, returnMaterial.iron, returnMaterial.ducat, enemyReturnMaterial.wood, enemyReturnMaterial.stone, enemyReturnMaterial.iron, enemyReturnMaterial.ducat);
	}*/
}