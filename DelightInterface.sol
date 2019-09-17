pragma solidity ^0.5.9;

interface DelightInterface {
	
	struct Record {
		uint order;
		address account;
		uint param1;
		uint param2;
		uint param3;
		uint param4;
		uint kill;
		uint death;
		bool isWin;
		uint time;
	}
	
	// 기록의 총 개수를 반환합니다.
	function getRecordCount() view external returns (uint);
	
	// 기록을 반환합니다.
	function getRecord(uint recordId) view external returns (
		uint order,
		address account,
		uint param1,
		uint param2,
		uint param3,
		uint param4,
		uint kill,
		uint death,
		bool isWin,
		uint time
	);
	
	// 전체 데미지를 가져옵니다.
	function getTotalDamage(uint distance, uint col, uint row) view external returns (uint);
	
	// 전체 원거리 데미지를 가져옵니다.
	function getTotalRangedDamage(uint distance, uint col, uint row) view external returns (uint);
	
	// 명령 큐를 실행합니다.
	function runOrderQueue(uint[] calldata orders, uint[] calldata params1, uint[] calldata params2, uint[] calldata params3, uint[] calldata params4) external;
}