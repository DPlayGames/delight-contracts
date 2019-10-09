pragma solidity ^0.5.9;

import "./DelightArmyManagerInterface.sol";
import "./DelightManager.sol";
import "./DelightBuildingManager.sol";
import "./DelightItemManager.sol";
import "./DelightKnightItemInterface.sol";
import "./Util/SafeMath.sol";

contract DelightArmyManager is DelightArmyManagerInterface, DelightManager {
	using SafeMath for uint;
	
	// The maximum number of units on a single tile.
	// 한 위치에 존재할 수 있는 최대 유닛 수
	uint constant private MAX_POSITION_UNIT_COUNT = 50;
	
	// The default buff HP of a knight.
	// 기사의 기본 버프 HP
	uint constant private KNIGHT_DEFAULT_BUFF_HP = 10;
	
	// Delight building manager
	// Delight 건물 관리자
	DelightBuildingManager private buildingManager;
	
	// Delight item manager
	// Delight 아이템 관리자
	DelightItemManager private itemManager;
	
	// 기사 아이템
	DelightKnightItemInterface private knightItem;
	
	constructor() DelightManager() public {
		
		if (network == Network.Mainnet) {
			
			// Knight item.
			// 기사 아이템
			knightItem = DelightKnightItemInterface(0x79078dDe3b55d2dCAd5e5a4Aa84F08FB7d25368a);
		}
		
		else if (network == Network.Kovan) {
			
			// Knight item.
			// 기사 아이템
			knightItem = DelightKnightItemInterface(0xcaF1daACDC81F78b58BE9e48dC2585F2952dd8B9);
		}
		
		else if (network == Network.Ropsten) {
			
			// Knight item.
			// 기사 아이템
			knightItem = DelightKnightItemInterface(0xeF7cb3ac85E3b15CF3004a3Ea89e26DFAFb9D371);
		}
		
		else if (network == Network.Rinkeby) {
			
			// Knight item.
			// 기사 아이템
			knightItem = DelightKnightItemInterface(0x7bAD16534354FDFd0B020f54237eE4F61fB03726);
		}
		
		else {
			revert();
		}
		
		// 0번지는 사용하지 않습니다.
		armies.push(Army({
			unitKind : 99,
			unitCount : 0,
			knightItemId : 0,
			col : COL_RANGE,
			row : ROW_RANGE,
			owner : address(0),
			createTime : 0
		}));
	}
	
	function setDelightBuildingManagerOnce(address addr) external {
		
		// The address must be empty.
		// 비어있는 주소인 경우에만
		require(address(buildingManager) == address(0));
		
		buildingManager = DelightBuildingManager(addr);
	}
	
	function setDelightItemManagerOnce(address addr) external {
		
		// The address must be empty.
		// 비어있는 주소인 경우에만
		require(address(itemManager) == address(0));
		
		itemManager = DelightItemManager(addr);
	}
	
	// Executed only when the sender is Delight.
	// Sender가 Delight일때만 실행
	modifier onlyDelight() {
		require(
			msg.sender == delight ||
			msg.sender == address(buildingManager) ||
			msg.sender == address(itemManager)
		);
		_;
	}
	
	Army[] internal armies;
	
	mapping(uint => mapping(uint => uint[])) internal positionToArmyIds;
	mapping(uint => Reward) private battleIdToReward;
	
	// Returns the total number of armies.
	// 부대의 총 개수를 반환합니다.
	function getArmyCount() view external returns (uint) {
		return armies.length;
	}
	
	// Returns the information of the army.
	// 부대의 정보를 반환합니다.
	function getArmyInfo(uint armyId) view external returns (
		uint unitKind,
		uint unitCount,
		uint knightItemId,
		uint col,
		uint row,
		address owner,
		uint createTime
	) {
		Army memory army = armies[armyId];
		
		return (
			army.unitKind,
			army.unitCount,
			army.knightItemId,
			army.col,
			army.row,
			army.owner,
			army.createTime
		);
	}
	
	// 보상 정보를 반환합니다.
	function getRewardInfo(uint battleId) view external returns (
		uint wood,
		uint stone,
		uint iron,
		uint ducat
	) {
		Reward memory reward = battleIdToReward[battleId];
		
		return (
			reward.wood,
			reward.stone,
			reward.iron,
			reward.ducat
		);
	}
	
	// Gets the IDs of the armies in a specific tile.
	// 특정 위치에 존재하는 부대의 ID들을 가져옵니다.
	function getPositionArmyIds(uint col, uint row) view external returns (uint[] memory) {
		return positionToArmyIds[col][row];
	}
	
	// Gets the owners of the armies in a specific tile.
	// 특정 위치에 존재하는 부대의 소유주를 가져옵니다.
	function getPositionOwner(uint col, uint row) view external returns (address) {
		
		uint[] memory armyIds = positionToArmyIds[col][row];
		
		for (uint i = 0; i < armyIds.length; i += 1) {
			
			address owner = armies[armyIds[i]].owner;
			if (owner != address(0)) {
				return owner;
			}
		}
		
		return address(0);
	}
	
	// 특정 위치의 총 유닛 숫자를 계산합니다.
	function getTotalUnitCount(uint distance, uint col, uint row) view public returns (uint) {
		
		uint[] memory armyIds = positionToArmyIds[col][row];
		
		uint totalUnitCount = 0;
		for (uint i = 0; i < armyIds.length; i += 1) {
			
			// Check if the unit can reach the distance.
			// 이동이 가능한 거리인지 확인합니다.
			if (distance <= info.getUnitMovableDistance(armies[armyIds[i]].unitKind)) {
				totalUnitCount = totalUnitCount.add(armies[armyIds[i]].unitCount);
			}
		}
		
		return totalUnitCount;
	}
	
	// Creates armies.
	// 부대를 생산합니다.
	function createArmy(address owner, uint col, uint row, uint unitKind, uint unitCount) onlyDelight external {
		
		uint[] storage armyIds = positionToArmyIds[col][row];
		
		// The total number of units in the building's tile must not exceed the maximum unit number.
		// 건물이 위치한 곳의 총 유닛 숫자가 최대 유닛 수를 넘기면 안됩니다.
		require(getTotalUnitCount(0, col, row).add(unitCount) <= MAX_POSITION_UNIT_COUNT);
		
		// 기사는 하나 이상 생성할 수 없습니다.
		require(unitKind != UNIT_KNIGHT || unitCount == 1);
		
		uint materialWood = info.getUnitMaterialWood(unitKind).mul(unitCount);
		uint materialStone = info.getUnitMaterialStone(unitKind).mul(unitCount);
		uint materialIron = info.getUnitMaterialIron(unitKind).mul(unitCount);
		uint materialDucat = info.getUnitMaterialDucat(unitKind).mul(unitCount);
		
		// Checks if there's enough amount of required resources to create the army.
		// 부대를 생성하는데 필요한 자원이 충분한지 확인합니다.
		require(
			wood.balanceOf(owner) >= materialWood &&
			stone.balanceOf(owner) >= materialStone &&
			iron.balanceOf(owner) >= materialIron &&
			ducat.balanceOf(owner) >= materialDucat
		);
		
		armyIds.length = UNIT_KIND_COUNT;
		
		// If an army exists already, the number of units in the army increases.
		// 기존에 부대가 존재하면 부대원의 숫자 증가
		if (armyIds[unitKind] != 0) {
			
			// 기사는 추가할 수 없습니다.
			require(unitKind != UNIT_KNIGHT);
			
			armies[armyIds[unitKind]].unitCount = armies[armyIds[unitKind]].unitCount.add(unitCount);
		}
		
		// Creates a new army.
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
		
		// Transfers the resources to Delight.
		// 자원을 Delight로 이전합니다.
		wood.transferFrom(owner, delight, materialWood);
		stone.transferFrom(owner, delight, materialStone);
		iron.transferFrom(owner, delight, materialIron);
		ducat.transferFrom(owner, delight, materialDucat);
		
		// 이벤트 발생
		emit CreateArmy(armyIds[unitKind]);
	}
	
	// Equips items in the army.
	// 부대에 아이템을 장착합니다.
	function attachItem(address owner, uint armyId, uint itemKind, uint unitCount) onlyDelight external {
		
		Army storage army = armies[armyId];
		
		// Checks the owner of the army.
		// 부대의 소유주를 확인합니다.
		require(army.owner == owner);
		
		// Checks if there's enough units.
		// 유닛 수가 충분한지 확인합니다.
		require(army.unitCount >= unitCount);
		
		// Checks if the item is available for the type of army.
		// 부대의 성격과 아이템의 성격이 일치한지 확인합니다.
		require(
			// Swordsmen
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
			// Archers
			// 궁수
			(
				army.unitKind == UNIT_ARCHER &&
				(
					itemKind == ITEM_CROSSBOW ||
					itemKind == ITEM_BALLISTA ||
					itemKind == ITEM_CATAPULT
				)
			) ||
			// Cavalry
			// 기마병
			(
				army.unitKind == UNIT_CAVALY &&
				(
					itemKind == ITEM_CAMEL ||
					itemKind == ITEM_ELEPHANT
				)
			)
		);
		
		// Transfers items to Delight.
		// 아이템을 Delight로 이전합니다.
		itemManager.attachItem(owner, itemKind, unitCount);
		
		// Creates a new army, changing some of the units.
		// 유닛의 일부를 변경하여 새로운 부대를 생성합니다.
		
		// The type of the units of the new army.
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
		
		// If an army already exists, the number of units in the army increases.
		// 기존에 부대가 존재하면 부대원의 숫자 증가
		uint originArmyId = armyIds[unitKind];
		if (originArmyId != 0) {
			armies[originArmyId].unitCount = armies[originArmyId].unitCount.add(unitCount);
		}
		
		// Creates a new army.
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
			
			// 이벤트 발생
			emit CreateArmy(armyIds[unitKind]);
		}
		
		// 기존 부대원이 남아있지 않으면 제거합니다.
		if (army.unitCount == 0) {
			delete armyIds[army.unitKind];
			delete armies[armyId];
		}
		
		// 이벤트 발생
		emit AttachItem(armyId, armyIds[unitKind]);
	}
	
	// Equips an item to a knight.
	// 기사에 아이템을 장착합니다.
	function attachKnightItem(address owner, uint armyId, uint itemId) onlyDelight external {
		
		Army storage army = armies[armyId];
		
		// Check the army's owner.
		// 부대의 소유주를 확인합니다.
		require(army.owner == owner);
		
		// Check if it's a knight.
		// 기사인지 확인합니다.
		require(army.unitKind == UNIT_KNIGHT);
		
		// Check if the knight is already equipped with an item.
		// 기사가 아이템을 장착하고 있지 않은지 확인합니다.
		require(army.knightItemId == 0);
		
		// Transfers the item to Delight.
		// 아이템을 Delight로 이전합니다.
		itemManager.attachKnightItem(owner, itemId);
		
		// Assigns the knight item.
		// 기사 아이템을 지정합니다.
		army.knightItemId = itemId;
		
		// 이벤트 발생
		emit AttachKnightItem(armyId);
	}
	
	// Moves an army.
	// 부대의 위치를 이전합니다.
	function moveArmy(uint fromCol, uint fromRow, uint toCol, uint toRow) onlyDelight external {
		
		// 위치가 달라야 합니다.
		require(fromCol != toCol || fromRow != toRow);
		
		// Calculates distance.
		// 거리 계산
		uint distance = (fromCol < toCol ? toCol - fromCol : fromCol - toCol) + (fromRow < toRow ? toRow - fromRow : fromRow - toRow);
		
		uint[] storage armyIds = positionToArmyIds[fromCol][fromRow];
		uint[] storage targetArmyIds = positionToArmyIds[toCol][toRow];
		
		targetArmyIds.length = UNIT_KIND_COUNT;
		
		// Calculate the total number of units in the tile where the merge take place.
		// 병합할 위치에 존재하는 총 유닛 숫자를 계산합니다.
		uint totalUnitCount = getTotalUnitCount(0, toCol, toRow);
		
		for (uint i = 0; i < UNIT_KIND_COUNT; i += 1) {
			
			Army memory army = armies[armyIds[i]];
			
			if (
			// The number of units must be bigger than 0.
			// 유닛의 개수가 0개 이상이어야 합니다.
			army.unitCount > 0 &&
			
			// Check if the unit can reach the distance.
			// 이동이 가능한 거리인지 확인합니다.
			distance <= info.getUnitMovableDistance(army.unitKind)) {
				
				moveArmyOne(totalUnitCount, armyIds[i], army.unitCount, toCol, toRow);
			}
		}
	}
	
	// 단일 부대의 위치를 이전합니다.
	function moveArmyOne(uint totalUnitCount, uint armyId, uint unitCount, uint toCol, uint toRow) onlyDelight public {
		
		Army storage army = armies[armyId];
		
		uint[] storage armyIds = positionToArmyIds[army.col][army.row];
		
		uint[] storage targetArmyIds = positionToArmyIds[toCol][toRow];
		
		targetArmyIds.length = UNIT_KIND_COUNT;
		
		Army storage targetArmy = armies[targetArmyIds[army.unitKind]];
		
		// If the number of units exceeds the maximum number when just moving,
		// 그대로 이동했을 때 존재할 수 있는 최대 유닛의 숫자를 넘는 경우
		if (totalUnitCount.add(unitCount) > MAX_POSITION_UNIT_COUNT) {
			
			uint movableUnitCount = MAX_POSITION_UNIT_COUNT.sub(totalUnitCount);
			
			// 이동할 유닛은 1개 이상이어야합니다.
			require(movableUnitCount > 0);
			
			// Creates a new army if it's empty.
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
				
				army.unitCount = army.unitCount.sub(movableUnitCount);
				
				// 이벤트 발생
				emit CreateArmy(targetArmyIds[army.unitKind]);
			}
			
			// Merges with an existing army if it isn't empty.
			// 비어있지 않으면 병합합니다.
			else {
				
				// 기사는 병합할 수 없습니다.
				require(army.unitKind != UNIT_KNIGHT);
				
				targetArmy.unitCount = targetArmy.unitCount.add(movableUnitCount);
				army.unitCount = army.unitCount.sub(movableUnitCount);
			}
			
			// 이벤트 발생
			emit MergeArmy(armyId, targetArmyIds[army.unitKind], movableUnitCount);
			
			// 기존 부대원이 남아있지 않으면 제거합니다.
			if (army.unitCount == 0) {
				delete armyIds[army.unitKind];
				delete armies[armyId];
			}
		}
		
		// 모든 유닛 이동
		else if (army.unitCount == unitCount) {
			
			// move if the tile is empty.
			// 비어있는 곳이면 이전합니다.
			if (targetArmy.unitCount == 0) {
				
				targetArmyIds[army.unitKind] = armyId;
				
				army.col = toCol;
				army.row = toRow;
				
				// 이벤트 발생
				emit MoveArmy(armyId);
				
				delete armyIds[army.unitKind];
			}
			
			// merge with an existing army if it isn't empty.
			// 비어있지 않으면 병합합니다.
			else {
				
				// 기사는 병합할 수 없습니다.
				require(army.unitKind != UNIT_KNIGHT);
				
				targetArmy.unitCount = targetArmy.unitCount.add(army.unitCount);
				
				// 이벤트 발생
				emit MergeArmy(armyId, targetArmyIds[army.unitKind], army.unitCount);
				
				delete armyIds[army.unitKind];
				delete armies[armyId];
			}
		}
		
		// 일부 유닛 이동
		else {
			
			// Creates a new army if it's empty.
			// 비어있는 곳이면 새 부대를 생성합니다.
			if (targetArmy.unitCount == 0) {
				
				targetArmyIds[army.unitKind] = armies.push(Army({
					unitKind : army.unitKind,
					unitCount : unitCount,
					knightItemId : 0,
					col : toCol,
					row : toRow,
					owner : army.owner,
					createTime : now
				})).sub(1);
				
				army.unitCount = army.unitCount.sub(unitCount);
				
				// 이벤트 발생
				emit CreateArmy(targetArmyIds[army.unitKind]);
			}
			
			// Merges with an existing army if it isn't empty.
			// 비어있지 않으면 병합합니다.
			else {
				
				// 기사는 병합할 수 없습니다.
				require(army.unitKind != UNIT_KNIGHT);
				
				targetArmy.unitCount = targetArmy.unitCount.add(unitCount);
				army.unitCount = army.unitCount.sub(unitCount);
			}
			
			// 이벤트 발생
			emit MergeArmy(armyId, targetArmyIds[army.unitKind], unitCount);
		}
	}
	
	function getItemKindByUnitKind(uint unitKind) pure private returns (uint) {
		
		if (unitKind == UNIT_AXEMAN) {
			return ITEM_AXE;
		} else if (unitKind == UNIT_SPEARMAN) {
			return ITEM_SPEAR;
		} else if (unitKind == UNIT_SHIELDMAN) {
			return ITEM_SHIELD;
		} else if (unitKind == UNIT_SPY) {
			return ITEM_HOOD;
		}
		
		else if (unitKind == UNIT_CROSSBOWMAN) {
			return ITEM_CROSSBOW;
		} else if (unitKind == UNIT_BALLISTA) {
			return ITEM_BALLISTA;
		} else if (unitKind == UNIT_CATAPULT) {
			return ITEM_CATAPULT;
		}
		
		else if (unitKind == UNIT_CAMELRY) {
			return ITEM_CAMEL;
		} else if (unitKind == UNIT_WAR_ELEPHANT) {
			return ITEM_ELEPHANT;
		}
		
		return 0;
	}
	
	// Attack
	// 부대를 공격합니다.
	function attack(uint battleId, uint totalDamage, uint distance, uint col, uint row) onlyDelight external returns (uint totalDeadUnitCount) {
		
		uint damage = totalDamage;
		
		// Loot
		// 전리품
		Reward storage reward = battleIdToReward[battleId];
		
		uint[] storage armyIds = positionToArmyIds[col][row];
		
		for (uint i = 0; i < UNIT_KIND_COUNT; i += 1) {
			
			Army storage army = armies[armyIds[i]];
			
			if (
			// The number of units must be more than 0.
			// 유닛의 개수가 0개 이상이어야 합니다.
			army.unitCount > 0 &&
			
			// Check if the units can reach the distance.
			// 이동이 가능한 거리인지 확인합니다.
			distance <= info.getUnitMovableDistance(army.unitKind)) {
				
				// 유닛의 체력을 계산합니다.
				uint unitHP = info.getUnitHP(army.unitKind).add(
					
					// Adds the knight item's HP if the unit's a knight.
					// 기사인 경우 기사 아이템의 HP를 추가합니다.
					i == UNIT_KNIGHT ? knightItem.getItemHP(army.knightItemId) : (
						
						// If the unit's not a knight, adds the knight's buff HP.
						// 기사가 아닌 경우 기사의 버프 HP를 추가합니다.
						armyIds[UNIT_KNIGHT] != 0 && distance <= info.getUnitMovableDistance(UNIT_KNIGHT) ? KNIGHT_DEFAULT_BUFF_HP + knightItem.getItemBuffHP(armies[armyIds[UNIT_KNIGHT]].knightItemId) : 0
					)
					
				).add(
					
					// 이동 거리가 0일때만 병사 위치의 건물의 버프 HP를 가져옵니다.
					distance == 0 ? buildingManager.getBuildingBuffHP(col, row) : 0
				);
				
				// Calcultes the HPs of the friendly army.
				// 아군의 체력을 계산합니다.
				uint armyHP = unitHP.mul(army.unitCount);
				
				armyHP = armyHP <= damage ? 0 : armyHP.sub(damage);
				
				// Calculates the result of the battle.
				// 전투 결과를 계산합니다.
				uint remainUnitCount = armyHP.add(
					
					// 나머지가 남지 않도록
					armyHP % unitHP == 0 ? 0 : unitHP.sub(armyHP % unitHP)
					
				).div(unitHP);
				
				uint deadUnitCount = army.unitCount.sub(remainUnitCount);
				
				// Lowers the total damage of the enemy.
				// 적의 총 데미지를 낮춥니다.
				damage = damage <= deadUnitCount.mul(unitHP) ? 0 : damage.sub(deadUnitCount.mul(unitHP));
				
				// 원거리 공격인 경우
				if (battleId == 0) {
					
					// Gets materials back.
					// 재료들을 돌려받습니다.
					wood.transferFrom(delight, army.owner, info.getUnitMaterialWood(army.unitKind).mul(deadUnitCount));
					stone.transferFrom(delight, army.owner, info.getUnitMaterialStone(army.unitKind).mul(deadUnitCount));
					iron.transferFrom(delight, army.owner, info.getUnitMaterialIron(army.unitKind).mul(deadUnitCount));
					ducat.transferFrom(delight, army.owner, info.getUnitMaterialDucat(army.unitKind).mul(deadUnitCount));
				}
				
				else {
					
					// Adds loot.
					// 전리품을 추가합니다.
					reward.wood = reward.wood.add(info.getUnitMaterialWood(army.unitKind).mul(deadUnitCount));
					reward.stone = reward.stone.add(info.getUnitMaterialStone(army.unitKind).mul(deadUnitCount));
					reward.iron = reward.iron.add(info.getUnitMaterialIron(army.unitKind).mul(deadUnitCount));
					reward.ducat = reward.ducat.add(info.getUnitMaterialDucat(army.unitKind).mul(deadUnitCount));
				}
				
				// Dismantles the equipped item.
				// 장착한 아이템을 분해합니다.
				if (getItemKindByUnitKind(army.unitKind) != 0) {
					itemManager.disassembleItem(getItemKindByUnitKind(army.unitKind), deadUnitCount);
				}
				
				// Saves the number of remaining units.
				// 남은 병사 숫자를 저장합니다.
				army.unitCount = remainUnitCount;
				
				// Adds to the number of total casualties.
				// 총 사망 병사 숫자에 추가합니다.
				totalDeadUnitCount = totalDeadUnitCount.add(deadUnitCount);
				
				// 이벤트 발생
				if (deadUnitCount > 0) {
					emit DeadUnits(armyIds[i]);
				}
				
				// The army was annihilated.
				// 부대가 전멸했습니다.
				if (army.unitCount == 0) {
					
					// 기사가 무기를 장착한 경우
					if (army.unitKind == UNIT_KNIGHT && army.knightItemId != 0) {
						
						// 원거리 공격인 경우
						if (battleId == 0) {
							
							// 기사 무기를 돌려받습니다.
							itemManager.transferKnightItem(army.owner, army.knightItemId);
						}
						
						else {
							
							// 기사 무기를 전리품에 추가합니다.
							reward.knightItemId = army.knightItemId;
						}
					}
					
					delete armies[armyIds[i]];
					delete armyIds[i];
				}
				
				// 살아남은 부대원이 있으면, 그대로 공격 종료
				else {
					break;
				}
			}
		}
	}
	
	// Destroys the building.
	// 건물을 파괴합니다.
	function destroyBuilding(uint battleId, uint col, uint row) onlyDelight external {
		
		// The building must exist.
		// 건물이 존재하는 경우에만
		if (buildingManager.getPositionBuildingId(col, row) != 0) {
			
			// Loot
			// 전리품
			Reward storage reward = battleIdToReward[battleId];
			
			(
				uint wood,
				uint stone,
				uint iron,
				uint ducat
			) = buildingManager.destroyBuilding(col, row);
			
			// Adds to the loot.
			// 전리품에 추가합니다.
			reward.wood = reward.wood.add(wood);
			reward.stone = reward.stone.add(stone);
			reward.iron = reward.iron.add(iron);
			reward.ducat = reward.ducat.add(ducat);
		}
	}
	
	// Achieved victory in the battle.
	// 전투에서 승리했습니다.
	function win(uint battleId, address winner) onlyDelight external {
	
		// Loot
		// 전리품
		Reward memory reward = battleIdToReward[battleId];
		
		// The winner takes the loot.
		// 승리자는 전리품을 취합니다.
		wood.transferFrom(delight, winner, reward.wood);
		stone.transferFrom(delight, winner, reward.stone);
		iron.transferFrom(delight, winner, reward.iron);
		ducat.transferFrom(delight, winner, reward.ducat);
		
		// 기사 무기를 전달합니다.
		if (reward.knightItemId != 0) {
			itemManager.transferKnightItem(winner, reward.knightItemId);
		}
	}
}
