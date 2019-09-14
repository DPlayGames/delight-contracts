pragma solidity ^0.5.9;

interface DelightHistoryInterface {
	
	event NewRecord(
		
		uint kind,
		
		address indexed owner,
		address indexed enemy,
		
		uint col,
		uint row,
		uint toCol,
		uint toRow,
		
		uint buildingId,
		uint buildingKind,
		uint buildingLevel,
		
		uint armyId,
		uint unitKind,
		uint unitCount,
		
		uint itemId,
		uint itemKind,
		uint itemCount,
		
		uint wood,
		uint stone,
		uint iron,
		uint ducat,
		
		uint time
	);
	
	event NewRecordDetail(
		
		uint indexed recordId,
		address indexed owner, 
		
		uint armyId,
		uint targetArmyId,
		
		uint unitKind,
		uint unitCount,
		
		uint buildingId,
		uint buildingKind,
		
		uint enemyWood,
		uint enemyStone,
		uint enemyIron,
		uint enemyDucat
	);
	
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
		
		uint time;
	}
	
	// 기록 상세 정보
	struct RecordDetail {
		
		address owner;
		
		uint armyId;
		uint targetArmyId;
		
		uint unitKind;
		uint unitCount;
		
		uint buildingId;
		uint buildingKind;
		
		uint enemyWood;
		uint enemyStone;
		uint enemyIron;
		uint enemyDucat;
	}
	
	// 건물 짓는 기록을 저장합니다.
	function recordBuild(
		
		address owner,
		
		// 건물 정보
		uint buildingId, uint buildingKind,
		uint col, uint row,
		
		// 재료
		uint wood, uint stone, uint iron, uint ducat
		
	) external returns (uint);
	
	// 본부를 업그레이드하는 기록을 저장합니다.
	function recordUpgradeHQ(
		
		address owner,
		
		// 건물 정보
		uint buildingId, uint buildingLevel,
		uint col, uint row,
		
		// 재료
		uint wood, uint stone, uint iron, uint ducat
		
	) external returns (uint);
	
	// 유닛을 추가하는 기록을 저장합니다.
	function recordAddUnits(
		
		address owner,
		
		// 건물 정보
		uint buildingId, uint buildingKind, uint buildingLevel,
		uint col, uint row,
		
		// 부대 정보
		uint armyId, uint unitKind, uint unitCount,
		
		// 재료
		uint wood, uint stone, uint iron, uint ducat
		
	) external returns (uint);
	
	// 부대를 생성하는 기록을 저장합니다.
	function recordCreateArmy(
		
		address owner,
		
		// 건물 정보
		uint buildingId, uint buildingKind, uint buildingLevel,
		uint col, uint row,
		
		// 부대 정보
		uint armyId, uint unitKind, uint unitCount,
		
		// 재료
		uint wood, uint stone, uint iron, uint ducat
		
	) external returns (uint);
	
	// 아이템을 생성하는 기록을 저장합니다.
	function recordCreateItem(
		
		address owner,
		
		// 아이템 정보
		uint itemKind, uint itemCount,
		
		// 재료
		uint wood, uint stone, uint iron, uint ducat
		
	) external returns (uint);
	
	// 아이템을 장착하는 기록을 저장합니다.
	function recordAttachItem(
		
		address owner,
		
		// 아이템 정보
		uint itemKind, uint itemCount,
		
		// 부대 정보
		uint armyId, uint unitKind,
		uint col, uint row
		
	) external returns (uint);
	
	// 기사 아이템을 장착하는 기록을 저장합니다.
	function recordAttachKnightItem(
		
		address owner,
		
		// 아이템 정보
		uint itemId,
		
		// 부대 정보
		uint armyId,
		uint col, uint row
		
	) external returns (uint);
	
	// 부대가 이동하는 기록을 저장합니다.
	function recordMoveArmy(
		
		address owner,
		
		// 위치 정보
		uint fromCol, uint fromRow, uint toCol, uint toRow
		
	) external returns (uint);
	
	// 부대가 병합하는 기록을 저장합니다.
	function recordMergeArmy(
		
		address owner,
		
		// 위치 정보
		uint fromCol, uint fromRow, uint toCol, uint toRow
		
	) external returns (uint);
	
	// 승리 기록을 저장합니다.
	function recordWin(
		
		address owner, address enemy,
		
		// 위치 정보
		uint fromCol, uint fromRow, uint toCol, uint toRow,
		
		// 전리품
		uint wood, uint stone, uint iron, uint ducat
		
	) external returns (uint);
	
	// 패배 기록을 저장합니다.
	function recordLose(
		
		address owner, address enemy,
		
		// 위치 정보
		uint fromCol, uint fromRow, uint toCol, uint toRow,
		
		// 전리품
		uint wood, uint stone, uint iron, uint ducat
		
	) external returns (uint);
	
	// 원거리 공격 기록을 저장합니다.
	function recordRangedAttack(
		
		address owner, address enemy,
		
		// 위치 정보
		uint fromCol, uint fromRow, uint toCol, uint toRow,
		
		// 돌려받을 자원
		uint wood, uint stone, uint iron, uint ducat
		
	) external returns (uint);
	
	// 부대와 관련된 상세 기록을 추가합니다.
	function addArmyRecordDetail(
		
		uint recordId,
		address owner,
		
		// 부대 정보
		uint armyId, uint unitKind, uint unitCount
		
	) external;
	
	// 대상 부대와 관련된 상세 기록을 추가합니다.
	function addTargetArmyRecordDetail(
		
		uint recordId,
		address owner,
		
		// 부대 정보
		uint armyId, uint targetArmyId, uint unitKind, uint unitCount
		
	) external;
	
	// 건물과 관련된 상세 기록을 추가합니다.
	function addBuildingRecordDetail(
		
		uint recordId,
		address owner,
		
		// 건물 정보
		uint buildingId, uint buildingKind
		
	) external;
	
	// 적이 돌려받을 자원과 관련된 상세 기록을 추가합니다.
	function addEnemyResourceRecordDetail(
		
		uint recordId,
		address enemy,
		
		// 적이 돌려받을 자원
		uint enemyWood, uint enemyStone, uint enemyIron, uint enemyDucat
		
	) external;
}