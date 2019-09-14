pragma solidity ^0.5.9;

import "./DelightManager.sol";
import "./DelightBuildingManager.sol";
import "./DelightItemManager.sol";
import "./Util/SafeMath.sol";

contract DelightArmyManager is DelightManager {
	using SafeMath for uint;
	
	// 한 위치에 존재할 수 있는 최대 유닛 수
	uint constant private MAX_POSITION_UNIT_COUNT = 50;
	
	// 기사의 기본 버프
	uint constant internal KNIGHT_DEFAULT_BUFF_HP = 10;
	uint constant internal KNIGHT_DEFAULT_BUFF_DAMAGE = 5;
	
	// Delight 건물 관리자
	DelightBuildingManager public delightBuildingManager;
	
	// Delight 아이템 관리자
	DelightItemManager public delightItemManager;
	
	function setDelightBuildingManagerOnce(address addr) external {
		
		// 비어있는 주소인 경우에만
		require(address(delightBuildingManager) == address(0));
		
		delightBuildingManager = DelightBuildingManager(addr);
	}
	
	function setDelightItemManagerOnce(address addr) external {
		
		// 비어있는 주소인 경우에만
		require(address(delightItemManager) == address(0));
		
		delightItemManager = DelightItemManager(addr);
	}
	
	// Sender가 Delight일때만 실행
	modifier onlyDelight() {
		require(
			msg.sender == delight ||
			msg.sender == address(delightBuildingManager) ||
			msg.sender == address(delightItemManager)
		);
		_;
	}
	
	DelightKnightItem private knightItem;
	
	constructor() DelightManager() public {
		
		if (network == Network.Mainnet) {
			//TODO
		}
		
		else if (network == Network.Kovan) {
			//TODO
			
			// 기사 아이템
			knightItem	= DelightKnightItem(0x0c3ad341A711ECC43Ce5f18f0337F20A5861a60B);
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
	
	// 부대 정보
	struct Army {
		uint unitKind;
		uint unitCount;
		uint knightItemId;
		uint col;
		uint row;
		address owner;
		uint createTime;
	}
	
	Army[] internal armies;
	
	mapping(uint => mapping(uint => uint[])) internal positionToArmyIds;
	
	// 특정 위치에 존재하는 부대의 소유주를 가져옵니다.
	function getPositionOwner(uint col, uint row) view public returns (address) {
		
		uint[] memory armyIds = positionToArmyIds[col][row];
		
		for (uint i = 0; i < armyIds.length; i += 1) {
			
			address owner = armies[armyIds[i]].owner;
			if (owner != address(0x0)) {
				return owner;
			}
		}
		
		return address(0x0);
	}
	
	// 부대를 생산합니다.
	function createArmy(address owner, uint col, uint row, uint unitKind, uint unitCount) onlyDelight external {
		
		// 건물이 위치한 곳의 총 유닛 숫자를 계산합니다.
		uint[] storage armyIds = positionToArmyIds[col][row];
		
		uint totalUnitCount = unitCount;
		for (uint i = 0; i < armyIds.length; i += 1) {
			totalUnitCount = totalUnitCount.add(armies[armyIds[i]].unitCount);
		}
		
		// 건물이 위치한 곳의 총 유닛 숫자가 최대 유닛 수를 넘기면 안됩니다.
		require(totalUnitCount <= MAX_POSITION_UNIT_COUNT);
		
		uint materialWood = info.getUnitMaterialWood(unitKind).mul(unitCount);
		uint materialStone = info.getUnitMaterialStone(unitKind).mul(unitCount);
		uint materialIron = info.getUnitMaterialIron(unitKind).mul(unitCount);
		uint materialDucat = info.getUnitMaterialDucat(unitKind).mul(unitCount);
		
		// 부대를 생성하는데 필요한 자원이 충분한지 확인합니다.
		require(
			wood.balanceOf(owner) >= materialWood &&
			stone.balanceOf(owner) >= materialStone &&
			iron.balanceOf(owner) >= materialIron &&
			ducat.balanceOf(owner) >= materialDucat
		);
		
		armyIds.length = UNIT_KIND_COUNT;
		
		// 기존에 부대가 존재하면 부대원의 숫자 증가
		if (armyIds[unitKind] != 0) {
			armies[armyIds[unitKind]].unitCount = armies[armyIds[unitKind]].unitCount.add(unitCount);
		}
		
		// 새 부대 생성
		else {
			
			armyIds[unitKind] = armies.push(Army({
				unitKind : unitKind,
				unitCount : unitCount,
				knightItemId : 0,
				col : col,
				row : row,
				owner : owner,
				createTime : now
			})).sub(1);
		}
		
		// 자원을 Delight로 이전합니다.
		wood.transferFrom(owner, delight, materialWood);
		stone.transferFrom(owner, delight, materialStone);
		iron.transferFrom(owner, delight, materialIron);
		ducat.transferFrom(owner, delight, materialDucat);
	}
	
	// 부대에 아이템을 장착합니다.
	function attachItem(address owner, uint armyId, uint itemKind, uint unitCount) onlyDelight external {
		
		Army storage army = armies[armyId];
		
		// 부대의 소유주를 확인합니다.
		require(army.owner == owner);
		
		// 유닛 수가 충분한지 확인합니다.
		require(army.unitCount >= unitCount);
		
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
		
		// 아이템을 Delight로 이전합니다.
		delightItemManager.attachItem(owner, itemKind, unitCount);
		
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
		
		uint[] storage armyIds = positionToArmyIds[army.col][army.row];
		
		// 기존에 부대가 존재하면 부대원의 숫자 증가
		uint originArmyId = armyIds[unitKind];
		if (originArmyId != 0) {
			armies[originArmyId].unitCount = armies[originArmyId].unitCount.add(unitCount);
		}
		
		// 새 부대 생성
		else {
			
			armyIds[unitKind] = armies.push(Army({
				unitKind : unitKind,
				unitCount : unitCount,
				knightItemId : 0,
				col : army.col,
				row : army.row,
				owner : owner,
				createTime : now
			})).sub(1);
		}
	}
	
	// 기사에 아이템을 장착합니다.
	function attachKnightItem(address owner, uint armyId, uint itemId) onlyDelight external {
		
		Army storage army = armies[armyId];
		
		// 부대의 소유주를 확인합니다.
		require(army.owner == owner);
		
		// 기사인지 확인합니다.
		require(army.unitKind == UNIT_KNIGHT);
		
		// 기사가 아이템을 장착하고 있지 않은지 확인합니다.
		require(army.knightItemId == 0);
		
		// 아이템을 Delight로 이전합니다.
		delightItemManager.attachKnightItem(owner, itemId);
		
		// 기사 아이템을 지정합니다.
		army.knightItemId = itemId;
	}
	
	// 부대의 위치를 이전합니다.
	function moveArmy(uint fromCol, uint fromRow, uint toCol, uint toRow) onlyDelight external {
		
		// 거리 계산
		uint distance = (fromCol < toCol ? toCol - fromCol : fromCol - toCol) + (fromRow < toRow ? toRow - fromRow : fromRow - toRow);
		
		uint[] storage armyIds = positionToArmyIds[fromCol][fromRow];
		uint[] storage targetArmyIds = positionToArmyIds[toCol][toRow];
		
		targetArmyIds.length = UNIT_KIND_COUNT;
		
		for (uint i = 0; i < UNIT_KIND_COUNT; i += 1) {
			
			Army storage army = armies[armyIds[i]];
			
			if (
			// 유닛의 개수가 0개 이상이어야 합니다.
			army.unitCount > 0 &&
			
			// 이동이 가능한 거리인지 확인합니다.
			distance <= info.getUnitMovableDistance(army.unitKind)) {
				
				targetArmyIds[i] = armyIds[i];
				
				delete armyIds[i];
			}
		}
	}
	
	// 부대를 병합합니다.
	function mergeArmy(uint fromCol, uint fromRow, uint toCol, uint toRow) onlyDelight external {
		
		// 거리 계산
		uint distance = (fromCol < toCol ? toCol - fromCol : fromCol - toCol) + (fromRow < toRow ? toRow - fromRow : fromRow - toRow);
		
		uint[] storage armyIds = positionToArmyIds[fromCol][fromRow];
		uint[] storage targetArmyIds = positionToArmyIds[toCol][toRow];
		
		targetArmyIds.length = UNIT_KIND_COUNT;
		
		// 병합할 위치에 존재하는 총 유닛 숫자를 계산합니다.
		uint totalUnitCount = 0;
		for (uint i = 0; i < UNIT_KIND_COUNT; i += 1) {
			totalUnitCount = totalUnitCount.add(armies[targetArmyIds[i]].unitCount);
		}
		
		for (uint i = 0; i < UNIT_KIND_COUNT; i += 1) {
			
			Army storage army = armies[armyIds[i]];
			
			if (
			// 유닛의 개수가 0개 이상이어야 합니다.
			army.unitCount > 0 &&
			
			// 이동이 가능한 거리인지 확인합니다.
			distance <= info.getUnitMovableDistance(army.unitKind)) {
				
				Army storage targetArmy = armies[targetArmyIds[i]];
				
				// 그대로 이동했을 때 존재할 수 있는 최대 유닛의 숫자를 넘는 경우
				if (totalUnitCount.add(army.unitCount) > MAX_POSITION_UNIT_COUNT) {
					
					uint movableUnitCount = MAX_POSITION_UNIT_COUNT.sub(totalUnitCount);
					
					// 비어있는 곳이면 새 부대를 생성합니다.
					if (targetArmy.unitCount == 0) {
						
						targetArmyIds[army.unitKind] = armies.push(Army({
							unitKind : army.unitKind,
							unitCount : movableUnitCount,
							knightItemId : 0,
							col : toCol,
							row : toRow,
							owner : army.owner,
							createTime : now
						})).sub(1);
					}
					
					// 비어있지 않으면 병합합니다.
					else {
						
						targetArmy.unitCount = targetArmy.unitCount.add(movableUnitCount);
						army.unitCount = army.unitCount.sub(movableUnitCount);
					}
				}
				
				// 그대로 이동 가능할 때
				else {
					
					// 비어있는 곳이면 이전합니다.
					if (targetArmy.unitCount == 0) {
						
						targetArmyIds[i] = armyIds[i];
						
						delete armyIds[i];
					}
					
					// 비어있지 않으면 합병합니다.
					else {
						
						targetArmy.unitCount = targetArmy.unitCount.add(army.unitCount);
						
						delete armies[armyIds[i]];
						delete armyIds[i];
					}
				}
			}
		}
	}
	
	// 전체 데미지를 가져옵니다.
	function getTotalDamage(uint distance, uint col, uint row) view external returns (uint) {
		
		uint[] memory armyIds = positionToArmyIds[col][row];
		
		uint totalDamage = 0;
		
		// 총 공격력을 계산합니다.
		for (uint i = 0; i < UNIT_KIND_COUNT; i += 1) {
			
			Army memory army = armies[armyIds[i]];
			
			if (
			// 유닛의 개수가 0개 이상이어야 합니다.
			army.unitCount > 0 &&
			
			// 이동이 가능한 거리인지 확인합니다.
			distance <= info.getUnitMovableDistance(army.unitKind)) {
				
				// 아군의 공격력 추가
				totalDamage = totalDamage.add(
					info.getUnitDamage(army.unitKind).add(
						
						// 기사인 경우 기사 아이템의 공격력을 추가합니다.
						i == UNIT_KNIGHT ? knightItem.getItemDamage(army.knightItemId) : (
							
							// 기사가 아닌 경우 기사의 버프 데미지를 추가합니다.
							armyIds[UNIT_KNIGHT] != 0 == true ? KNIGHT_DEFAULT_BUFF_DAMAGE + knightItem.getItemBuffDamage(armies[armyIds[UNIT_KNIGHT]].knightItemId) : 0
						)
						
					).mul(army.unitCount)
				);
			}
		}
		
		return totalDamage;
	}
	
	// 전체 원거리 데미지를 가져옵니다.
	function getTotalRangedDamage(uint distance, uint col, uint row) view external returns (uint) {
		
		uint[] memory armyIds = positionToArmyIds[col][row];
		
		uint totalDamage = 0;
		
		// 총 공격력을 계산합니다.
		for (uint i = 0; i < UNIT_KIND_COUNT; i += 1) {
			
			Army memory army = armies[armyIds[i]];
			
			if (
			// 유닛의 개수가 0개 이상이어야 합니다.
			army.unitCount > 0 &&
			
			// 공격이 가능한 거리인지 확인합니다.
			distance <= info.getUnitAttackableDistance(army.unitKind)) {
				
				// 아군의 공격력 추가
				totalDamage = totalDamage.add(
					info.getUnitDamage(army.unitKind).add(
						
						// 기사인 경우 기사 아이템의 공격력을 추가합니다.
						i == UNIT_KNIGHT ? knightItem.getItemDamage(army.knightItemId) : (
							
							// 기사가 아닌 경우 기사의 버프 데미지를 추가합니다.
							armyIds[UNIT_KNIGHT] != 0 == true ? KNIGHT_DEFAULT_BUFF_DAMAGE + knightItem.getItemBuffDamage(armies[armyIds[UNIT_KNIGHT]].knightItemId) : 0
						)
						
					).mul(army.unitCount)
				);
			}
		}
		
		return totalDamage;
	}
	
	// 부대를 공격합니다.
	function attack(address owner, address enemy, uint totalDamage, uint distance, uint col, uint row) onlyDelight external {
		
		uint damage = totalDamage;
		
		// 전리품
		uint rewardWood = 0;
		uint rewardStone = 0;
		uint rewardIron = 0;
		uint rewardDucat = 0;
		
		uint[] storage armyIds = positionToArmyIds[col][row];
		
		for (uint i = 0; i < UNIT_KIND_COUNT; i += 1) {
			
			Army storage army = armies[armyIds[i]];
			
			if (
			// 유닛의 개수가 0개 이상이어야 합니다.
			army.unitCount > 0 &&
			
			// 이동이 가능한 거리인지 확인합니다.
			distance <= info.getUnitMovableDistance(army.unitKind)) {
				
				// 아군의 체력을 계산합니다.
				uint armyHP = info.getUnitHP(army.unitKind).add(
					
					// 기사인 경우 기사 아이템의 HP를 추가합니다.
					i == UNIT_KNIGHT ? knightItem.getItemHP(army.knightItemId) : (
						
						// 기사가 아닌 경우 기사의 버프 HP를 추가합니다.
						armyIds[UNIT_KNIGHT] != 0 == true ? KNIGHT_DEFAULT_BUFF_HP + knightItem.getItemBuffHP(armies[armyIds[UNIT_KNIGHT]].knightItemId) : 0
					)
					
				).mul(army.unitCount);
				
				armyHP = armyHP <= damage ? 0 : armyHP.sub(damage);
				
				// 전투 결과를 계산합니다.
				uint remainUnitCount = armyHP.add(armyHP % info.getUnitHP(army.unitKind)).div(info.getUnitHP(army.unitKind));
				uint deadUnitCount = army.unitCount.sub(remainUnitCount);
				
				// 적의 총 공격력을 낮춥니다.
				damage = damage <= deadUnitCount.mul(info.getUnitHP(army.unitKind)) ? 0 : damage.sub(deadUnitCount.mul(info.getUnitHP(army.unitKind)));
				
				// 전리품을 계산합니다.
				rewardWood = rewardWood.add(info.getUnitMaterialWood(army.unitKind).mul(deadUnitCount));
				rewardStone = rewardStone.add(info.getUnitMaterialStone(army.unitKind).mul(deadUnitCount));
				rewardIron = rewardIron.add(info.getUnitMaterialIron(army.unitKind).mul(deadUnitCount));
				rewardDucat = rewardDucat.add(info.getUnitMaterialDucat(army.unitKind).mul(deadUnitCount));
				
				// 남은 병사 숫자를 저장합니다.
				army.unitCount = remainUnitCount;
				
				// 병사가 전멸했습니다.
				if (army.unitCount == 0) {
					delete armies[armyIds[i]];
					delete armyIds[i];
				}
			}
		}
		
		// 승리
		if (damage >= 0) {
			
			// 전리품을 얻습니다.
			wood.transferFrom(delight, owner, rewardWood);
			stone.transferFrom(delight, owner, rewardStone);
			iron.transferFrom(delight, owner, rewardIron);
			ducat.transferFrom(delight, owner, rewardDucat);
		}
		
		// 패배
		else {
			
			// 전리품을 얻습니다.
			wood.transferFrom(delight, enemy, rewardWood);
			stone.transferFrom(delight, enemy, rewardStone);
			iron.transferFrom(delight, enemy, rewardIron);
			ducat.transferFrom(delight, enemy, rewardDucat);
		}
	}
	
	// 부대를 원거리에서 공격합니다.
	function rangedAttack(address enemy, uint totalDamage, uint distance, uint col, uint row) onlyDelight external {
		
		uint damage = totalDamage;
		
		// 돌려받을 재료들
		uint returnWood = 0;
		uint returnStone = 0;
		uint returnIron = 0;
		uint returnDucat = 0;
		
		uint[] storage armyIds = positionToArmyIds[col][row];
		
		for (uint i = 0; i < UNIT_KIND_COUNT; i += 1) {
			
			Army storage army = armies[armyIds[i]];
			
			if (
			// 유닛의 개수가 0개 이상이어야 합니다.
			army.unitCount > 0 &&
			
			// 공격이 가능한 거리인지 확인합니다.
			distance <= info.getUnitAttackableDistance(army.unitKind)) {
				
				// 아군의 체력을 계산합니다.
				uint armyHP = info.getUnitHP(army.unitKind).add(
					
					// 기사인 경우 기사 아이템의 HP를 추가합니다.
					i == UNIT_KNIGHT ? knightItem.getItemHP(army.knightItemId) : (
						
						// 기사가 아닌 경우 기사의 버프 HP를 추가합니다.
						armyIds[UNIT_KNIGHT] != 0 == true ? KNIGHT_DEFAULT_BUFF_HP + knightItem.getItemBuffHP(armies[armyIds[UNIT_KNIGHT]].knightItemId) : 0
					)
					
				).mul(army.unitCount);
				
				armyHP = armyHP <= damage ? 0 : armyHP.sub(damage);
				
				// 전투 결과를 계산합니다.
				uint remainUnitCount = armyHP.add(armyHP % info.getUnitHP(army.unitKind)).div(info.getUnitHP(army.unitKind));
				uint deadUnitCount = army.unitCount.sub(remainUnitCount);
				
				// 적의 총 공격력을 낮춥니다.
				damage = damage <= deadUnitCount.mul(info.getUnitHP(army.unitKind)) ? 0 : damage.sub(deadUnitCount.mul(info.getUnitHP(army.unitKind)));
				
				// 돌려받을 재료들을 계산합니다.
				returnWood = returnWood.add(info.getUnitMaterialWood(army.unitKind).mul(deadUnitCount));
				returnStone = returnStone.add(info.getUnitMaterialStone(army.unitKind).mul(deadUnitCount));
				returnIron = returnIron.add(info.getUnitMaterialIron(army.unitKind).mul(deadUnitCount));
				returnDucat = returnDucat.add(info.getUnitMaterialDucat(army.unitKind).mul(deadUnitCount));
				
				// 남은 병사 숫자를 저장합니다.
				army.unitCount = remainUnitCount;
				
				// 병사가 전멸했습니다.
				if (army.unitCount == 0) {
					delete armies[armyIds[i]];
					delete armyIds[i];
				}
			}
		}
		
		// 재료들을 돌려받습니다.
		wood.transferFrom(delight, enemy, returnWood);
		stone.transferFrom(delight, enemy, returnStone);
		iron.transferFrom(delight, enemy, returnIron);
		ducat.transferFrom(delight, enemy, returnDucat);
	}
}