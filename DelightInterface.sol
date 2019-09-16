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
	
	// 명령 큐를 실행합니다.
	function runOrderQueue(uint[] calldata orders, uint[] calldata params1, uint[] calldata params2, uint[] calldata params3, uint[] calldata params4) external;
}