pragma solidity ^0.5.9;

interface DelightInterface {
	
	// Events
	// 이벤트
    event Move				(address indexed owner, uint fromCol, uint fromRow, uint toCol, uint toRow);
    event MoveArmy			(address indexed owner, uint fromArmyId, uint toArmyId, uint unitCount);
    
    event Win				(address indexed owner, address indexed enemy, uint fromCol, uint fromRow, uint toCol, uint toRow, uint wood, uint stone, uint iron, uint ducat);
    event Lose				(address indexed owner, address indexed enemy, uint fromCol, uint fromRow, uint toCol, uint toRow, uint wood, uint stone, uint iron, uint ducat);
    event RangedAttack		(address indexed owner, address indexed enemy, uint fromCol, uint fromRow, uint toCol, uint toRow, uint wood, uint stone, uint iron, uint ducat, uint enemyWood, uint enemyStone, uint enemyIron, uint enemyDucat);
    event DeadUnits			(address indexed owner, uint armyId, uint unitCount);
    
    event CreateItem		(address indexed owner, uint itemKind, uint count, uint wood, uint stone, uint iron, uint ducat);
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
}