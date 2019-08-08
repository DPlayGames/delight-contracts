pragma solidity ^0.5.9;

interface DelightInterface {
	
	// 건물 정보
	struct Building {
		uint kind;
	}
	
	// 부대 정보
	struct Army {
		uint kind;
		uint count;
	}
}