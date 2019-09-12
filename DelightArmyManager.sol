pragma solidity ^0.5.9;

import "./DelightBase.sol";
import "./DelightItem.sol";
import "./Util/SafeMath.sol";

contract DelightArmyManager is DelightBase {
	using SafeMath for uint;
	
	// 부대를 이동시키고, 해당 지역에 적이 있으면 공격합니다.
	function moveAndAttack(uint col, uint row, uint toCol, uint toRow) internal {
		
		// 올바른 범위인지 체크합니다.
		require(col < COL_RANGE && row < ROW_RANGE);
		require(toCol < COL_RANGE && toRow < ROW_RANGE);
		
		// 부대의 소유주를 확인합니다.
		require(getArmyOwnerByPosition(col, row) == msg.sender);
		
		// 거리 계산
		uint distance = (col < toCol ? toCol - col : col - toCol) + (row < toRow ? toRow - row : row - toRow);
		
		// 전리품
		Material memory rewardMaterial = Material({
			wood : 0,
			stone : 0,
			iron : 0,
			ducat : 0
		});
		
		address targetArmyOwner = getArmyOwnerByPosition(toCol, toRow);
		
		uint[] storage armyIds = positionToArmyIds[col][row];
		uint[] storage targetArmyIds = positionToArmyIds[toCol][toRow];
		
		// 아군이 위치한 곳이면 부대를 합병합니다.
		if (targetArmyOwner == msg.sender) {
			
			targetArmyIds.length = UNIT_KIND_COUNT;
			
			for (uint i = 0; i < UNIT_KIND_COUNT; i += 1) {
				
				Army storage army = armies[armyIds[i]];
				
				if (
				// 유닛의 개수가 0개 이상이어야 합니다.
				army.unitCount > 0 &&
				
				// 이동이 가능한 거리인지 확인합니다.
				distance <= units[army.unitKind].movableDistance) {
					
					Army storage targetArmy = armies[targetArmyIds[i]];
					
					// 비어있는 곳이면 이전합니다.
					if (targetArmy.unitCount == 0) {
						
						targetArmyIds[i] = armyIds[i];
						
						delete armyIds[i];
					}
					
					// 비어있지 않으면 합병합니다.
					else {
						
						targetArmy.unitCount = targetArmy.unitCount.add(army.unitCount);
						
						army.unitCount = 0;
						army.owner = address(0x0);
						
						delete armyIds[i];
					}
				}
			}
		}
		
		// 적군이 위치한 곳이면 공격합니다.
		else {
			
			uint totalDamage = 0;
			uint totalEnemyDamage = 0;
			
			// 총 공격력을 계산합니다.
			for (uint i = 0; i < UNIT_KIND_COUNT; i += 1) {
				
				Army memory army = armies[armyIds[i]];
				
				if (
				// 유닛의 개수가 0개 이상이어야 합니다.
				army.unitCount > 0 &&
				
				// 이동이 가능한 거리인지 확인합니다.
				distance <= units[army.unitKind].movableDistance) {
					
					// 아군의 공격력 추가
					totalDamage = totalDamage.add(
						units[army.unitKind].damage.add(
							
							// 기사인 경우 기사 아이템의 공격력을 추가합니다.
							i == UNIT_KNIGHT ? knightItem.getItemDamage(army.knightItemId) : (
								
								// 기사가 아닌 경우 기사의 버프 데미지를 추가합니다.
								armyIds[UNIT_KNIGHT] != 0 == true ? KNIGHT_DEFAULT_BUFF_DAMAGE + knightItem.getItemBuffDamage(armies[armyIds[UNIT_KNIGHT]].knightItemId) : 0
							)
							
						).mul(army.unitCount)
					);
				}
				
				Army memory enemyArmy = armies[targetArmyIds[i]];
				
				// 유닛의 개수가 0개 이상이어야 합니다.
				if (enemyArmy.unitCount > 0) {
					
					// 적군의 공격력 추가
					totalEnemyDamage = totalEnemyDamage.add(
						units[enemyArmy.unitKind].damage.add(
							
							// 기사인 경우 기사 아이템의 공격력을 추가합니다.
							i == UNIT_KNIGHT ? knightItem.getItemDamage(enemyArmy.knightItemId) : (
								
								// 기사가 아닌 경우 기사의 버프 데미지를 추가합니다.
								targetArmyIds[UNIT_KNIGHT] != 0 == true ? KNIGHT_DEFAULT_BUFF_DAMAGE + knightItem.getItemBuffDamage(armies[targetArmyIds[UNIT_KNIGHT]].knightItemId) : 0
							)
							
						).mul(enemyArmy.unitCount)
					);
				}
			}
			
			// 전투를 개시합니다.
			for (uint i = 0; i < UNIT_KIND_COUNT; i += 1) {
				
				// 적군이 아군을 공격합니다.
				Army storage army = armies[armyIds[i]];
				
				if (
				// 유닛의 개수가 0개 이상이어야 합니다.
				army.unitCount > 0 &&
				
				// 이동이 가능한 거리인지 확인합니다.
				distance <= units[army.unitKind].movableDistance) {
					
					// 아군의 체력을 계산합니다.
					uint armyHP = units[army.unitKind].hp.add(
						
						// 기사인 경우 기사 아이템의 HP를 추가합니다.
						i == UNIT_KNIGHT ? knightItem.getItemHP(army.knightItemId) : (
							
							// 기사가 아닌 경우 기사의 버프 HP를 추가합니다.
							armyIds[UNIT_KNIGHT] != 0 == true ? KNIGHT_DEFAULT_BUFF_HP + knightItem.getItemBuffHP(armies[armyIds[UNIT_KNIGHT]].knightItemId) : 0
						)
						
					).mul(army.unitCount);
					
					armyHP = armyHP <= totalEnemyDamage ? 0 : armyHP.sub(totalEnemyDamage);
					
					// 전투 결과를 계산합니다.
					uint remainUnitCount = armyHP.add(armyHP % units[army.unitKind].hp).div(units[army.unitKind].hp);
					uint deadUnitCount = army.unitCount.sub(remainUnitCount);
					
					// 적의 총 공격력을 낮춥니다.
					totalEnemyDamage = totalEnemyDamage <= deadUnitCount.mul(units[army.unitKind].hp) ? 0 : totalEnemyDamage.sub(deadUnitCount.mul(units[army.unitKind].hp));
					
					// 전리품을 계산합니다.
					Material memory unitMaterial = unitMaterials[army.unitKind];
					rewardMaterial.wood = rewardMaterial.wood.add(unitMaterial.wood.mul(deadUnitCount));
					rewardMaterial.stone = rewardMaterial.wood.add(unitMaterial.stone.mul(deadUnitCount));
					rewardMaterial.iron = rewardMaterial.wood.add(unitMaterial.iron.mul(deadUnitCount));
					rewardMaterial.ducat = rewardMaterial.wood.add(unitMaterial.ducat.mul(deadUnitCount));
					
					// 남은 병사 숫자를 저장합니다.
					army.unitCount = remainUnitCount;
					if (army.unitCount == 0) {
						army.owner = address(0x0);
					}
				}
				
				// 아군이 적군을 공격합니다.
				Army storage enemyArmy = armies[targetArmyIds[i]];
				
				// 유닛의 개수가 0개 이상이어야 합니다.
				if (enemyArmy.unitCount > 0) {
					
					// 적군의 체력을 계산합니다.
					uint ememyArmyHP = units[enemyArmy.unitKind].hp.add(
						
						// 기사인 경우 기사 아이템의 HP를 추가합니다.
						i == UNIT_KNIGHT ? knightItem.getItemHP(enemyArmy.knightItemId) : (
							
							// 기사가 아닌 경우 기사의 버프 HP를 추가합니다.
							targetArmyIds[UNIT_KNIGHT] != 0 == true ? KNIGHT_DEFAULT_BUFF_HP + knightItem.getItemBuffHP(armies[targetArmyIds[UNIT_KNIGHT]].knightItemId) : 0
						)
						
					).mul(enemyArmy.unitCount);
					
					ememyArmyHP = ememyArmyHP <= totalDamage ? 0 : ememyArmyHP.sub(totalDamage);
					
					// 전투 결과를 계산합니다.
					uint remainEnemyUnitCount = ememyArmyHP.add(ememyArmyHP % units[enemyArmy.unitKind].hp).div(units[enemyArmy.unitKind].hp);
					uint deadEnemyUnitCount = enemyArmy.unitCount.sub(remainEnemyUnitCount);
					
					// 아군의 총 공격력을 낮춥니다.
					totalDamage = totalDamage <= deadEnemyUnitCount.mul(units[enemyArmy.unitKind].hp) ? 0 : totalDamage.sub(deadEnemyUnitCount.mul(units[enemyArmy.unitKind].hp));
					
					// 전리품을 계산합니다.
					rewardMaterial.wood = rewardMaterial.wood.add(unitMaterials[enemyArmy.unitKind].wood.mul(deadEnemyUnitCount));
					rewardMaterial.stone = rewardMaterial.wood.add(unitMaterials[enemyArmy.unitKind].stone.mul(deadEnemyUnitCount));
					rewardMaterial.iron = rewardMaterial.wood.add(unitMaterials[enemyArmy.unitKind].iron.mul(deadEnemyUnitCount));
					rewardMaterial.ducat = rewardMaterial.wood.add(unitMaterials[enemyArmy.unitKind].ducat.mul(deadEnemyUnitCount));
					
					// 남은 병사 숫자를 저장합니다.
					enemyArmy.unitCount = remainEnemyUnitCount;
					if (enemyArmy.unitCount == 0) {
						enemyArmy.owner = address(0x0);
					}
				}
			}
			
			// 승리
			if (totalDamage >= totalEnemyDamage) {
				
				targetArmyIds.length = UNIT_KIND_COUNT;
				
				// 승리하면 병력을 이동합니다.
				for (uint i = 0; i < UNIT_KIND_COUNT; i += 1) {
					
					Army memory army = armies[armyIds[i]];
					
					if (
					// 유닛의 개수가 0개 이상이어야 합니다.
					army.unitCount > 0 &&
					
					// 이동이 가능한 거리인지 확인합니다.
					distance <= units[army.unitKind].movableDistance) {
						
						targetArmyIds[i] = armyIds[i];
						
						delete armyIds[i];
					}
				}
				
				// 전리품을 취득합니다.
				wood.transferFrom(address(this), msg.sender, rewardMaterial.wood);
				stone.transferFrom(address(this), msg.sender, rewardMaterial.stone);
				iron.transferFrom(address(this), msg.sender, rewardMaterial.iron);
				ducat.transferFrom(address(this), msg.sender, rewardMaterial.ducat);
			}
			
			// 패배
			else {
				
				// 패배하면 상대방이 전리품을 취득합니다.
				wood.transferFrom(address(this), targetArmyOwner, rewardMaterial.wood);
				stone.transferFrom(address(this), targetArmyOwner, rewardMaterial.stone);
				iron.transferFrom(address(this), targetArmyOwner, rewardMaterial.iron);
				ducat.transferFrom(address(this), targetArmyOwner, rewardMaterial.ducat);
			}
		}
	}
	
	// 원거리 유닛으로 특정 지역을 공격합니다.
	function rangedAttack(uint col, uint row, uint toCol, uint toRow) internal {
		
		// 올바른 범위인지 체크합니다.
		require(col < COL_RANGE && row < ROW_RANGE);
		require(toCol < COL_RANGE && toRow < ROW_RANGE);
		
		// 부대의 소유주를 확인합니다.
		require(getArmyOwnerByPosition(col, row) == msg.sender);
		
		address targetArmyOwner = getArmyOwnerByPosition(toCol, toRow);
		
		// 아군을 공격할 수 없습니다.
		require(targetArmyOwner != msg.sender);
		
		// 거리 계산
		uint distance = (col < toCol ? toCol - col : col - toCol) + (row < toRow ? toRow - row : row - toRow);
		
		uint[] storage armyIds = positionToArmyIds[col][row];
		uint[] storage targetArmyIds = positionToArmyIds[toCol][toRow];
		
		uint totalDamage = 0;
		uint totalEnemyDamage = 0;
		
		// 총 공격력을 계산합니다.
		for (uint i = 0; i < UNIT_KIND_COUNT; i += 1) {
			
			Army memory army = armies[armyIds[i]];
			
			if (
			// 유닛의 개수가 0개 이상이어야 합니다.
			army.unitCount > 0 &&
			
			// 공격이 가능한 거리인지 확인합니다.
			distance <= units[army.unitKind].attackableDistance) {
				
				// 아군의 공격력 추가
				totalDamage = totalDamage.add(
					units[army.unitKind].damage.add(
						
						// 기사인 경우 기사 아이템의 공격력을 추가합니다.
						i == UNIT_KNIGHT ? knightItem.getItemDamage(army.knightItemId) : (
							
							// 기사가 아닌 경우 기사의 버프 데미지를 추가합니다.
							armyIds[UNIT_KNIGHT] != 0 == true ? KNIGHT_DEFAULT_BUFF_DAMAGE + knightItem.getItemBuffDamage(armies[armyIds[UNIT_KNIGHT]].knightItemId) : 0
						)
						
					).mul(army.unitCount)
				);
			}
			
			Army memory enemyArmy = armies[targetArmyIds[i]];
			
			if (
			// 유닛의 개수가 0개 이상이어야 합니다.
			enemyArmy.unitCount > 0 &&
			
			// 공격이 가능한 거리인지 확인합니다.
			distance <= units[enemyArmy.unitKind].attackableDistance) {
				
				// 적군의 공격력 추가
				totalEnemyDamage = totalEnemyDamage.add(
					units[enemyArmy.unitKind].damage.add(
						
						// 기사인 경우 기사 아이템의 공격력을 추가합니다.
						i == UNIT_KNIGHT ? knightItem.getItemDamage(enemyArmy.knightItemId) : (
							
							// 기사가 아닌 경우 기사의 버프 데미지를 추가합니다.
							targetArmyIds[UNIT_KNIGHT] != 0 == true ? KNIGHT_DEFAULT_BUFF_DAMAGE + knightItem.getItemBuffDamage(armies[targetArmyIds[UNIT_KNIGHT]].knightItemId) : 0
						)
						
					).mul(enemyArmy.unitCount)
				);
			}
		}
		
		// 전투를 개시합니다.
		for (uint i = 0; i < UNIT_KIND_COUNT; i += 1) {
			
			// 적군이 아군을 공격합니다.
			Army storage army = armies[armyIds[i]];
			
			// 유닛의 개수가 0개 이상이어야 합니다.
			if (army.unitCount > 0) {
				
				// 아군의 체력을 계산합니다.
				uint armyHP = units[army.unitKind].hp.add(
					
					// 기사인 경우 기사 아이템의 HP를 추가합니다.
					i == UNIT_KNIGHT ? knightItem.getItemHP(army.knightItemId) : (
						
						// 기사가 아닌 경우 기사의 버프 HP를 추가합니다.
						armyIds[UNIT_KNIGHT] != 0 == true ? KNIGHT_DEFAULT_BUFF_HP + knightItem.getItemBuffHP(armies[armyIds[UNIT_KNIGHT]].knightItemId) : 0
					)
					
				).mul(army.unitCount);
				
				armyHP = armyHP <= totalEnemyDamage ? 0 : armyHP.sub(totalEnemyDamage);
				
				// 전투 결과를 계산합니다.
				uint remainUnitCount = armyHP.add(armyHP % units[army.unitKind].hp).div(units[army.unitKind].hp);
				uint deadUnitCount = army.unitCount.sub(remainUnitCount);
				
				// 적의 총 공격력을 낮춥니다.
				totalEnemyDamage = totalEnemyDamage <= deadUnitCount.mul(units[army.unitKind].hp) ? 0 : totalEnemyDamage.sub(deadUnitCount.mul(units[army.unitKind].hp));
				
				// 일방적인 공격일 경우 자원을 그대로 돌려받습니다.
				wood.transferFrom(address(this), msg.sender, unitMaterials[army.unitKind].wood.mul(deadUnitCount));
				stone.transferFrom(address(this), msg.sender, unitMaterials[army.unitKind].stone.mul(deadUnitCount));
				iron.transferFrom(address(this), msg.sender, unitMaterials[army.unitKind].iron.mul(deadUnitCount));
				ducat.transferFrom(address(this), msg.sender, unitMaterials[army.unitKind].ducat.mul(deadUnitCount));
				
				// 남은 병사 숫자를 저장합니다.
				army.unitCount = remainUnitCount;
				if (army.unitCount == 0) {
					army.owner = address(0x0);
				}
			}
			
			// 아군이 적군을 공격합니다.
			Army storage enemyArmy = armies[targetArmyIds[i]];
			
			// 유닛의 개수가 0개 이상이어야 합니다.
			if (enemyArmy.unitCount > 0) {
				
				// 적군의 체력을 계산합니다.
				uint ememyArmyHP = units[enemyArmy.unitKind].hp.add(
					
					// 기사인 경우 기사 아이템의 HP를 추가합니다.
					i == UNIT_KNIGHT ? knightItem.getItemHP(enemyArmy.knightItemId) : (
						
						// 기사가 아닌 경우 기사의 버프 HP를 추가합니다.
						targetArmyIds[UNIT_KNIGHT] != 0 == true ? KNIGHT_DEFAULT_BUFF_HP + knightItem.getItemBuffHP(armies[targetArmyIds[UNIT_KNIGHT]].knightItemId) : 0
					)
					
				).mul(enemyArmy.unitCount);
				
				ememyArmyHP = ememyArmyHP <= totalDamage ? 0 : ememyArmyHP.sub(totalDamage);
				
				// 전투 결과를 계산합니다.
				uint remainEnemyUnitCount = ememyArmyHP.add(ememyArmyHP % units[enemyArmy.unitKind].hp).div(units[enemyArmy.unitKind].hp);
				uint deadEnemyUnitCount = enemyArmy.unitCount.sub(remainEnemyUnitCount);
				
				// 아군의 총 공격력을 낮춥니다.
				totalDamage = totalDamage <= deadEnemyUnitCount.mul(units[enemyArmy.unitKind].hp) ? 0 : totalDamage.sub(deadEnemyUnitCount.mul(units[enemyArmy.unitKind].hp));
				
				// 일방적인 공격일 경우 자원을 그대로 돌려받습니다.
				wood.transferFrom(address(this), targetArmyOwner, unitMaterials[army.unitKind].wood.mul(deadEnemyUnitCount));
				stone.transferFrom(address(this), targetArmyOwner, unitMaterials[army.unitKind].stone.mul(deadEnemyUnitCount));
				iron.transferFrom(address(this), targetArmyOwner, unitMaterials[army.unitKind].iron.mul(deadEnemyUnitCount));
				ducat.transferFrom(address(this), targetArmyOwner, unitMaterials[army.unitKind].ducat.mul(deadEnemyUnitCount));
				
				// 남은 병사 숫자를 저장합니다.
				enemyArmy.unitCount = remainEnemyUnitCount;
				if (enemyArmy.unitCount == 0) {
					enemyArmy.owner = address(0x0);
				}
			}
		}
	}
	
	// 부대에 아이템을 장착합니다.
	function attachItem(uint armyId, uint itemKind, uint unitCount) internal {
		
		Army storage army = armies[armyId];
		
		// 부대의 소유주를 확인합니다.
		require(army.owner == msg.sender);
		
		// 유닛 수가 충분한지 확인합니다.
		require(army.unitCount >= unitCount);
		
		DelightItem itemContract = getItemContract(itemKind);
		
		// 아이템 수가 충분한지 확인합니다.
		require(itemContract.balanceOf(msg.sender) >= unitCount);
		
		// 부대의 성격과 아이템의 성격이 일치한지 확인합니다.
		require(
			// 검병
			(
				army.unitKind == UNIT_SWORDSMAN &&
				(
					itemKind == ITEM_AXE ||
					itemKind == ITEM_SPEAR ||
					itemKind == ITEM_SHIELD ||
					itemKind == ITEM_HOOD
				)
			) ||
			
			// 궁수
			(
				army.unitKind == UNIT_ARCHER &&
				(
					itemKind == ITEM_CROSSBOW ||
					itemKind == ITEM_BALLISTA ||
					itemKind == ITEM_CATAPULT
				)
			) ||
			
			// 기마병
			(
				army.unitKind == UNIT_CAVALY &&
				(
					itemKind == ITEM_CAMEL ||
					itemKind == ITEM_ELEPHANT
				)
			)
		);
		
		// 유닛의 일부를 변경하여 새로운 부대를 생성합니다.
		
		// 새 부대 유닛의 성격
		uint unitKind;
		
		if (itemKind == ITEM_AXE) {
			unitKind = UNIT_AXEMAN;
		} else if (itemKind == ITEM_SPEAR) {
			unitKind = UNIT_SPEARMAN;
		} else if (itemKind == ITEM_SHIELD) {
			unitKind = UNIT_SHIELDMAN;
		} else if (itemKind == ITEM_HOOD) {
			unitKind = UNIT_SPY;
		}
		
		else if (itemKind == ITEM_CROSSBOW) {
			unitKind = UNIT_CROSSBOWMAN;
		} else if (itemKind == ITEM_BALLISTA) {
			unitKind = UNIT_BALLISTA;
		} else if (itemKind == ITEM_CATAPULT) {
			unitKind = UNIT_CATAPULT;
		}
		
		else if (itemKind == ITEM_CAMEL) {
			unitKind = UNIT_CAMELRY;
		} else if (itemKind == ITEM_ELEPHANT) {
			unitKind = UNIT_WAR_ELEPHANT;
		}
		
		army.unitCount = army.unitCount.sub(unitCount);
		
		positionToArmyIds[army.col][army.row].length = UNIT_KIND_COUNT;
		
		// 기존에 부대가 존재하면 부대원의 숫자 증가
		uint originArmyId = positionToArmyIds[army.col][army.row][unitKind];
		if (originArmyId != 0) {
			armies[originArmyId].unitCount = armies[originArmyId].unitCount.add(unitCount);
		}
		
		// 새 부대 생성
		else {
			
			uint newArmyId = armies.push(Army({
				unitKind : unitKind,
				unitCount : unitCount,
				knightItemId : 0,
				col : army.col,
				row : army.row,
				owner : msg.sender,
				createTime : now
			})).sub(1);
			
			positionToArmyIds[army.col][army.row][unitKind] = newArmyId;
		}
		
		// 아이템을 Delight로 이전합니다.
		itemContract.transferFrom(msg.sender, address(this), unitCount);
	}
	
	// 기사에 아이템을 장착합니다.
	function attachKnightItem(uint armyId, uint itemId) internal {
		
		Army storage army = armies[armyId];
		
		// 부대의 소유주를 확인합니다.
		require(army.owner == msg.sender);
		
		// 기사인지 확인합니다.
		require(army.unitKind == UNIT_KNIGHT);
		
		// 기사가 아이템을 장착하고 있지 않은지 확인합니다.
		require(army.knightItemId == 0);
		
		// 아이템을 소유하고 있는지 확인합니다.
		require(knightItem.ownerOf(itemId) == msg.sender);
		
		// 기사 아이템을 지정합니다.
		army.knightItemId = itemId;
		
		// 아이템을 Delight로 이전합니다.
		knightItem.transferFrom(msg.sender, address(this), itemId);
	}
}