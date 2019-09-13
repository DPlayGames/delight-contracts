pragma solidity ^0.5.9;

interface DelightInterface {
	
	// Events
	// 이벤트
    event Build				(address indexed owner, uint buildingId, uint kind, uint col, uint row, uint bulidTime);
    event UpgradeHQ			(address indexed owner, uint buildingId, uint level, uint col, uint row);
    event DestroyBuilding	(address indexed owner, uint buildingId, uint kind, uint col, uint row);
    
    event CreateArmy		(address indexed owner, uint armyId, uint unitKind, uint unitCount, uint col, uint row, uint createTime);
    event AddUnits			(address indexed owner, uint armyId, uint unitKind, uint unitCount, uint col, uint row);
    
    event Move				(address indexed owner, uint fromCol, uint fromRow, uint toCol, uint toRow);
    event MoveArmy			(address indexed owner, uint fromArmyId, uint toArmyId, uint unitCount);
    
    event MoveAndAttack		(address indexed owner, uint fromCol, uint fromRow, uint toCol, uint toRow, uint wood, uint stone, uint iron, uint ducat);
    event RangedAttack		(address indexed owner, uint fromCol, uint fromRow, uint toCol, uint toRow, uint wood, uint stone, uint iron, uint ducat, uint enemyWood, uint enemyStone, uint enemyIron, uint enemyDucat);
    event DeadUnits			(address indexed owner, uint armyId, uint unitCount);
    
    event CreateItem		(address indexed owner, uint itemKind, uint count);
    event AttachItem		(address indexed owner, uint armyId, uint itemKind, uint count);
    event AttackKnightItem	(address indexed owner, uint armyId, uint itemId);
	
	// 건물 정보
	struct Building {
		uint kind;
		uint level;
		uint col;
		uint row;
		address owner;
		uint buildTime;
	}
	
	// 유닛 정보
	struct Unit {
		uint hp;
		uint damage;
		uint movableDistance;
		uint attackableDistance;
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
	
	// 재료 정보
	struct Material {
		uint wood;
		uint stone;
		uint iron;
		uint ducat;
	}
	
	// 기록 정보
	struct Record {
		
		uint kind;
		
		address owner;
		address enemy;
		
		uint col;
		uint row;
		uint toCol;
		uint toRow;
		
		uint buildingId;
		uint buildingKind;
		uint buildingLevel;
		
		uint armyId;
		uint unitKind;
		uint unitCount;
		
		uint itemId;
		uint itemKind;
		uint itemCount;
		
		uint wood;
		uint stone;
		uint iron;
		uint ducat;
		
		uint enemyWood;
		uint enemyStone;
		uint enemyIron;
		uint enemyDucat;
		
		uint time;
	}
	
	// 기록 상세 정보
	struct RecordDetail {
		
		uint recordId;
		
		uint armyId;
		uint toArmyId;
		
		uint unitKind;
		uint unitCount;
	}
}