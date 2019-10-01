pragma solidity ^0.5.9;

interface DelightInterface {
	
	// Events
	// 이벤트들
	event NewRecord(address indexed owner, uint indexed recordId);
	
	struct Record {
		uint order;
		address account;
		address enemy;
		uint param1;
		uint param2;
		uint param3;
		uint param4;
		uint kill;
		uint death;
		bool isWin;
		uint time;
	}
	
	// Returns the total number of records.
	// 기록의 총 개수를 반환합니다.
	function getRecordCount() view external returns (uint);
	
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
	);
	
	// Gets the total damage.
	// 전체 데미지를 가져옵니다.
	function getTotalDamage(uint distance, uint col, uint row) view external returns (uint);
	
	// Gets the total ranged damage.
	// 전체 원거리 데미지를 가져옵니다.
	function getTotalRangedDamage(uint distance, uint col, uint row) view external returns (uint);
	
	// Executes the command queue
	// 명령 큐를 실행합니다.
	function runOrderQueue(uint[] calldata orders, uint[] calldata params1, uint[] calldata params2, uint[] calldata params3, uint[] calldata params4) external;
	
	// 마지막 공격 위치를 가져옵니다.
	function getLastAttackPosition() view external returns (uint col, uint row);
}
