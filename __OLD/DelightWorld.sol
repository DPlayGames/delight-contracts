pragma solidity ^0.5.9;

import "./DelightWorldInterface.sol";
import "./DelightBase.sol";
import "./DelightHistoryInterface.sol";
import "./Util/SafeMath.sol";

// 월드 관련 처리
contract DelightWorld is DelightWorldInterface, DelightBase {
	using SafeMath for uint;
	
	// Events
	// 이벤트
    event Build				(address indexed owner, uint buildingId, uint kind, uint col, uint row, uint bulidTime, uint wood, uint stone, uint iron, uint ducat);
    event UpgradeHQ			(address indexed owner, uint buildingId, uint level, uint col, uint row, uint wood, uint stone, uint iron, uint ducat);
    event DestroyBuilding	(address indexed owner, uint buildingId, uint kind, uint col, uint row);
    
    event CreateArmy		(address indexed owner, uint armyId, uint unitKind, uint unitCount, uint col, uint row, uint createTime, uint wood, uint stone, uint iron, uint ducat);
    event AddUnits			(address indexed owner, uint armyId, uint unitKind, uint unitCount, uint col, uint row, uint wood, uint stone, uint iron, uint ducat);
    
    event CreateItem		(address indexed owner, uint itemKind, uint count, uint wood, uint stone, uint iron, uint ducat);
    event AttachItem		(address indexed owner, uint armyId, uint itemKind, uint count);
    event AttackKnightItem	(address indexed owner, uint armyId, uint itemId);
	
	/*
	event MoveArmy			(address indexed owner, uint fromArmyId, uint toCol, uint toRow, uint unitCount);
	event MergeArmy			(address indexed owner, uint fromArmyId, uint toArmyId, uint unitCount);
    
    event Win				(address indexed owner, address indexed enemy, uint fromCol, uint fromRow, uint toCol, uint toRow, uint wood, uint stone, uint iron, uint ducat);
    event Lose				(address indexed owner, address indexed enemy, uint fromCol, uint fromRow, uint toCol, uint toRow, uint wood, uint stone, uint iron, uint ducat);
    event RangedAttack		(address indexed owner, address indexed enemy, uint fromCol, uint fromRow, uint toCol, uint toRow, uint wood, uint stone, uint iron, uint ducat, uint enemyWood, uint enemyStone, uint enemyIron, uint enemyDucat);
    event DeadUnits			(address indexed owner, uint armyId, uint unitCount);
	*/
	
	Building[] internal buildings;
	Army[] internal armies;
	
	mapping(uint => mapping(uint => uint)) internal positionToBuildingId;
	mapping(uint => mapping(uint => uint[])) internal positionToArmyIds;
	
	mapping(address => uint[]) internal ownerToHQIds;
	
	// Delight 주소
	address public delight;
	
	function setDelightOnce(address addr) external {
		
		// 비어있는 주소인 경우에만
		require(delight == address(0));
		
		delight = addr;
	}
	
	// Sender가 Delight일때만 실행
	modifier onlyDelight() {
		require(msg.sender == delight);
		_;
	}
	
	DelightHistoryInterface internal delightHistory;
	
	constructor() DelightBase() public {
		
		// DPlay History 스마트 계약을 불러옵니다.
		if (network == Network.Mainnet) {
			//TODO
		} else if (network == Network.Kovan) {
			//TODO
			delightHistory = DelightHistoryInterface(0x0);
		} else if (network == Network.Ropsten) {
			//TODO
		} else if (network == Network.Rinkeby) {
			//TODO
		} else {
			revert();
		}
		
		// 0번지는 사용하지 않습니다.
		buildings.push(Building({
			kind : 99,
			level : 0,
			col : COL_RANGE,
			row : ROW_RANGE,
			owner : msg.sender,
			buildTime : now
		}));
		
		// 0번지는 사용하지 않습니다.
		armies.push(Army({
			unitKind : 99,
			unitCount : 0,
			knightItemId : 0,
			col : COL_RANGE,
			row : ROW_RANGE,
			owner : msg.sender,
			createTime : now
		}));
	}
	
	// 특정 위치에 존재하는 부대의 소유주를 가져옵니다.
	function getArmyOwnerByPosition(uint col, uint row) view public returns (address) {
		
		uint[] memory armyIds = positionToArmyIds[col][row];
		
		for (uint i = 0; i < armyIds.length; i += 1) {
			
			address owner = armies[armyIds[i]].owner;
			if (owner != address(0x0)) {
				return owner;
			}
		}
		
		return address(0x0);
	}
	
	// 건물을 짓습니다.
	function build(address owner, uint kind, uint col, uint row) onlyDelight checkRange(col, row) external returns (uint) {
		
		// 필드에 건물이 존재하면 안됩니다.
		require(positionToBuildingId[col][row] == 0);
		
		// 필드에 적군이 존재하면 안됩니다.
		require(positionToArmyIds[col][row].length == 0 || getArmyOwnerByPosition(col, row) == owner);
		
		// 본부가 주변에 존재하는지 확인합니다.
		bool existsHQAround = false;
		for (uint i = 0; i < ownerToHQIds[owner].length; i += 1) {
			
			Building memory building = buildings[ownerToHQIds[owner][i]];
			uint hqCol = building.col;
			uint hqRow = building.row;
			
			if (
			(col < hqCol ? hqCol - col : col - hqCol) +
			(row < hqRow ? hqRow - row : row - hqRow) <= 5 + building.level.mul(2)
			) {
				existsHQAround = true;
				break;
			}
		}
		
		// 월드에 본부가 아예 없거나, 본부가 주변에 존재하는지 확인합니다.
		require(ownerToHQIds[owner].length == 0 || existsHQAround == true ||
		// 본부인 경우, 내 병사가 있는 위치에 지을 수 있습니다.
		(
			kind == BUILDING_HQ &&
			positionToArmyIds[col][row].length > 0 &&
			getArmyOwnerByPosition(col, row) == owner
		));
		
		// 만약 월드에 본부가 아예 없는 경우, 처음 짓는 곳 주변에 건물이 존재하면 안됩니다.
		if (ownerToHQIds[owner].length == 0) {
			for (uint i = (col <= 9 ? 0 : col - 9); i < (col >= 91 ? 100 : col + 9); i += 1) {
				for (uint j = (row <= 9 ? 0 : row - 9); j < (row >= 91 ? 100 : row + 9); j += 1) {
					require(positionToBuildingId[i][j] == 0);
				}
			}
		}
		
		Material memory material = buildingMaterials[kind];
		
		// 건물을 짓는데 필요한 자원이 충분한지 확인합니다.
		require(
			wood.balanceOf(owner) >= material.wood &&
			stone.balanceOf(owner) >= material.stone &&
			iron.balanceOf(owner) >= material.iron &&
			ducat.balanceOf(owner) >= material.ducat
		);
		
		uint bulidTime = now;
		
		uint buildingId = buildings.push(Building({
			kind : kind,
			level : 0,
			col : col,
			row : row,
			owner : owner,
			buildTime : now
		})).sub(1);
		
		positionToBuildingId[col][row] = buildingId;
		
		if (kind == BUILDING_HQ) {
			ownerToHQIds[owner].push(buildingId);
		}
		
		// 자원을 Delight로 이전합니다.
		wood.transferFrom(owner, delight, material.wood);
		stone.transferFrom(owner, delight, material.stone);
		iron.transferFrom(owner, delight, material.iron);
		ducat.transferFrom(owner, delight, material.ducat);
		
		// 기록을 저장합니다.
		delightHistory.recordBuild(owner, buildingId, kind, col, row, material.wood, material.stone, material.iron, material.ducat);
		
		// 이벤트 발생
		emit Build(owner, buildingId, kind, col, row, bulidTime, material.wood, material.stone, material.iron, material.ducat);
		
		return buildingId;
	}
	
	// 본부를 업그레이드합니다.
	function upgradeHQ(address owner, uint buildingId) onlyDelight external {
		
		Building storage building = buildings[buildingId];
		
		require(building.kind == BUILDING_HQ);
		
		Material memory material = hpUpgradeMaterials[building.level + 1];
		
		// 본부를 업그레이드하는데 필요한 자원이 충분한지 확인합니다.
		require(
			wood.balanceOf(owner) >= material.wood &&
			stone.balanceOf(owner) >= material.stone &&
			iron.balanceOf(owner) >= material.iron &&
			ducat.balanceOf(owner) >= material.ducat
		);
		
		// 최대 레벨은 2입니다. (0 ~ 2)
		require(building.level < 2);
		
		building.level += 1;
		
		// 자원을 Delight로 이전합니다.
		wood.transferFrom(owner, delight, material.wood);
		stone.transferFrom(owner, delight, material.stone);
		iron.transferFrom(owner, delight, material.iron);
		ducat.transferFrom(owner, delight, material.ducat);
		
		// 기록을 저장합니다.
		delightHistory.recordUpgradeHQ(owner, buildingId, building.level, building.col, building.row, material.wood, material.stone, material.iron, material.ducat);
		
		// 이벤트 발생
		emit UpgradeHQ(building.owner, buildingId, building.level, building.col, building.row, material.wood, material.stone, material.iron, material.ducat);
	}
	
	// 건물에서 부대를 생산합니다.
	function createArmy(address owner, uint buildingId, uint unitCount) onlyDelight external returns (uint) {
		
		// 건물 소유주만 부대 생산이 가능합니다.
		require(buildings[buildingId].owner == owner);
		
		// 건물이 위치한 곳의 총 유닛 숫자를 계산합니다.
		uint[] storage armyIds = positionToArmyIds[buildings[buildingId].col][buildings[buildingId].row];
		
		uint totalUnitCount = unitCount;
		for (uint i = 0; i < armyIds.length; i += 1) {
			totalUnitCount = totalUnitCount.add(armies[armyIds[i]].unitCount);
		}
		
		// 건물이 위치한 곳의 총 유닛 숫자가 최대 유닛 수를 넘기면 안됩니다.
		require(totalUnitCount <= MAX_POSITION_UNIT_COUNT);
		
		uint unitKind;
		
		// 본부의 경우 기사를 생산합니다.
		if (buildings[buildingId].kind == BUILDING_HQ) {
			
			// 이미 기사가 존재하는 곳이면, 취소합니다.
			if (armyIds.length == UNIT_KIND_COUNT && armyIds[UNIT_KNIGHT] != 0) {
				revert();
			} else {
				unitKind = UNIT_KNIGHT;
			}
		}
		
		// 훈련소의 경우 검병을 생산합니다.
		else if (buildings[buildingId].kind == BUILDING_TRAINING_CENTER) {
			unitKind = UNIT_SWORDSMAN;
		}
		
		// 사격소의 경우 궁수를 생산합니다.
		else if (buildings[buildingId].kind == BUILDING_TRAINING_CENTER) {
			unitKind = UNIT_ARCHER;
		}
		
		// 마굿간의 경우 기마병을 생산합니다.
		else if (buildings[buildingId].kind == BUILDING_STABLE) {
			unitKind = UNIT_CAVALY;
		}
		
		else {
			revert();
		}
		
		Material memory material = Material({
			wood : unitMaterials[unitKind].wood.mul(unitCount),
			stone : unitMaterials[unitKind].stone.mul(unitCount),
			iron : unitMaterials[unitKind].iron.mul(unitCount),
			ducat : unitMaterials[unitKind].ducat.mul(unitCount)
		});
		
		// 부대를 생성하는데 필요한 자원이 충분한지 확인합니다.
		require(
			wood.balanceOf(owner) >= material.wood &&
			stone.balanceOf(owner) >= material.stone &&
			iron.balanceOf(owner) >= material.iron &&
			ducat.balanceOf(owner) >= material.ducat
		);
		
		armyIds.length = UNIT_KIND_COUNT;
		
		// 기존에 부대가 존재하면 부대원의 숫자 증가
		if (armyIds[unitKind] != 0) {
			
			armies[armyIds[unitKind]].unitCount = armies[armyIds[unitKind]].unitCount.add(unitCount);
			
			// 기록을 저장합니다.
			delightHistory.recordAddUnits(owner, buildingId, buildings[buildingId].kind, buildings[buildingId].level, buildings[buildingId].col, buildings[buildingId].row, armyIds[unitKind], unitKind, unitCount, material.wood, material.stone, material.iron, material.ducat);
			
			// 이벤트 발생
			emit AddUnits(owner, armyIds[unitKind], unitKind, unitCount, buildings[buildingId].col, buildings[buildingId].row, material.wood, material.stone, material.iron, material.ducat);
		}
		
		// 새 부대 생성
		else {
			
			armyIds[unitKind] = armies.push(Army({
				unitKind : unitKind,
				unitCount : unitCount,
				knightItemId : 0,
				col : buildings[buildingId].col,
				row : buildings[buildingId].row,
				owner : owner,
				createTime : now
			})).sub(1);
			
			// 기록을 저장합니다.
			delightHistory.recordCreateArmy(owner, buildingId, buildings[buildingId].kind, buildings[buildingId].level, buildings[buildingId].col, buildings[buildingId].row, armyIds[unitKind], unitKind, unitCount, material.wood, material.stone, material.iron, material.ducat);
			
			// 이벤트 발생
			emit CreateArmy(owner, armyIds[unitKind], unitKind, unitCount, buildings[buildingId].col, buildings[buildingId].row, now, material.wood, material.stone, material.iron, material.ducat);
		}
		
		// 자원을 Delight로 이전합니다.
		wood.transferFrom(owner, delight, material.wood);
		stone.transferFrom(owner, delight, material.stone);
		iron.transferFrom(owner, delight, material.iron);
		ducat.transferFrom(owner, delight, material.ducat);
		
		return armyIds[unitKind];
	}
	
	// 아이템을 생성합니다.
	function createItem(address owner, uint kind, uint count) onlyDelight external returns (uint) {
		
		Material memory itemMaterial = itemMaterials[kind];
		Material memory material = Material({
			wood : itemMaterial.wood.mul(count),
			stone : itemMaterial.stone.mul(count),
			iron : itemMaterial.iron.mul(count),
			ducat : itemMaterial.ducat.mul(count)
		});
		
		// 아이템을 생산하는데 필요한 자원이 충분한지 확인합니다.
		require(
			wood.balanceOf(owner) >= material.wood &&
			stone.balanceOf(owner) >= material.stone &&
			iron.balanceOf(owner) >= material.iron &&
			ducat.balanceOf(owner) >= material.ducat
		);
		
		DelightItem itemContract = getItemContract(kind);
		
		itemContract.assemble(owner, count);
		
		// 기록을 저장합니다.
		delightHistory.recordCreateItem(owner, kind, count, material.wood, material.stone, material.iron, material.ducat);
		
		// 이벤트 발생
		emit CreateItem(owner, kind, count, material.wood, material.stone, material.iron, material.ducat);
	}
	
	// 부대에 아이템을 장착합니다.
	function attachItem(address owner, uint armyId, uint itemKind, uint unitCount) onlyDelight external {
		
		Army storage army = armies[armyId];
		
		// 부대의 소유주를 확인합니다.
		require(army.owner == owner);
		
		// 유닛 수가 충분한지 확인합니다.
		require(army.unitCount >= unitCount);
		
		DelightItem itemContract = getItemContract(itemKind);
		
		// 아이템 수가 충분한지 확인합니다.
		require(itemContract.balanceOf(owner) >= unitCount);
		
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
		
		uint[] storage armyIds = positionToArmyIds[army.col][army.row];
		
		armyIds.length = UNIT_KIND_COUNT;
		
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
		
		// 아이템을 Delight로 이전합니다.
		itemContract.transferFrom(owner, address(this), unitCount);
		
		// 기록을 저장합니다.
		delightHistory.recordAttachItem(owner, itemKind, unitCount, armyIds[unitKind], unitKind, army.col, army.row);
		
		// 이벤트 발생
		emit AttachItem(owner, armyIds[unitKind], itemKind, unitCount);
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
		
		// 아이템을 소유하고 있는지 확인합니다.
		require(knightItem.ownerOf(itemId) == owner);
		
		// 기사 아이템을 지정합니다.
		army.knightItemId = itemId;
		
		// 아이템을 Delight로 이전합니다.
		knightItem.transferFrom(owner, address(this), itemId);
		
		// 기록을 저장합니다.
		delightHistory.recordAttachKnightItem(owner, itemId, armyId, army.col, army.row);
		
		// 이벤트 발생
		emit AttackKnightItem(owner, armyId, itemId);
	}
	
	/*
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
			distance <= units[army.unitKind].movableDistance) {
				
				targetArmyIds[i] = armyIds[i];
				
				// 상세 기록을 저장합니다.
				delightHistory.addArmyRecordDetail(
					delightHistory.getRecordCount(),
					army.owner,
					armyIds[i],
					army.unitKind,
					army.unitCount
				);
				
				// 이벤트 발생
				emit MoveArmy(army.owner, armyIds[i], toCol, toRow, army.unitCount);
				
				delete armyIds[i];
			}
		}
	}
	
	// 부대를 병합합니다.
	function mergeArmy(uint fromCol, uint fromRow, uint toCol, uint toRow) onlyDelight external {
		
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
			(fromCol < toCol ? toCol - fromCol : fromCol - toCol) +
			(fromRow < toRow ? toRow - fromRow : fromRow - toRow) <= units[army.unitKind].movableDistance) {
				
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
						
						// 상세 기록을 저장합니다.
						delightHistory.addTargetArmyRecordDetail(
							delightHistory.getRecordCount(),
							army.owner,
							armyIds[i],
							targetArmyIds[i],
							army.unitKind,
							movableUnitCount
						);
						
						// 이벤트 발생
						emit MergeArmy(army.owner, armyIds[i], targetArmyIds[i], movableUnitCount);
					}
					
					// 비어있지 않으면 병합합니다.
					else {
						
						targetArmy.unitCount = targetArmy.unitCount.add(movableUnitCount);
						army.unitCount = army.unitCount.sub(movableUnitCount);
						
						// 상세 기록을 저장합니다.
						delightHistory.addTargetArmyRecordDetail(
							delightHistory.getRecordCount(),
							army.owner,
							armyIds[i],
							targetArmyIds[i],
							army.unitKind,
							movableUnitCount
						);
						
						// 이벤트 발생
						emit MergeArmy(army.owner, armyIds[i], targetArmyIds[i], movableUnitCount);
					}
				}
				
				// 그대로 이동 가능할 때
				else {
					
					// 비어있는 곳이면 이전합니다.
					if (targetArmy.unitCount == 0) {
						
						targetArmyIds[i] = armyIds[i];
						
						// 상세 기록을 저장합니다.
						delightHistory.addTargetArmyRecordDetail(
							delightHistory.getRecordCount(),
							army.owner,
							armyIds[i],
							targetArmyIds[i],
							army.unitKind,
							army.unitCount
						);
						
						// 이벤트 발생
						emit MergeArmy(army.owner, armyIds[i], targetArmyIds[i], army.unitCount);
						
						delete armyIds[i];
					}
					
					// 비어있지 않으면 합병합니다.
					else {
						
						targetArmy.unitCount = targetArmy.unitCount.add(army.unitCount);
						
						// 상세 기록을 저장합니다.
						delightHistory.addTargetArmyRecordDetail(
							delightHistory.getRecordCount(),
							army.owner,
							armyIds[i],
							targetArmyIds[i],
							army.unitKind,
							army.unitCount
						);
						
						// 이벤트 발생
						emit MergeArmy(army.owner, armyIds[i], targetArmyIds[i], army.unitCount);
						
						army.unitCount = 0;
						army.owner = address(0x0);
						
						delete armyIds[i];
					}
				}
			}
		}
	}
	*/
	
	/*
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
		}
		
		return totalDamage;
	}
	*/
	
	/*
	// 부대를 공격합니다.
	function attack(uint damage, uint distance, uint col, uint row) onlyDelight external {
		
		uint usedDamage = 0;
		
		uint[] storage armyIds = positionToArmyIds[col][row];
		
		// 전리품
		Material memory rewardMaterial = Material({
			wood : 0,
			stone : 0,
			iron : 0,
			ducat : 0
		});
		
		for (uint i = 0; i < UNIT_KIND_COUNT; i += 1) {
			
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
				
				armyHP = armyHP <= damage ? 0 : armyHP.sub(damage);
				
				// 전투 결과를 계산합니다.
				uint remainUnitCount = armyHP.add(armyHP % units[army.unitKind].hp).div(units[army.unitKind].hp);
				uint deadUnitCount = army.unitCount.sub(remainUnitCount);
				
				// 적의 총 공격력을 낮춥니다.
				usedDamage = usedDamage.add(deadUnitCount.mul(units[army.unitKind].hp));
				
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
				
				// 상세 기록을 저장합니다.
				delightHistory.addArmyRecordDetail(
					delightHistory.getRecordCount(),
					army.owner,
					armyIds[i],
					army.unitKind,
					deadUnitCount
				);
				
				// 이벤트 발생
				emit DeadUnits(army.owner, armyIds[i], deadUnitCount);
			}
		}
	}
	
	// 원거리 공격을 개시합니다.
	function rangedAttack(address owner, address enemy, uint fromCol, uint fromRow, uint toCol, uint toRow) onlyDelight external {
	}
	*/
}