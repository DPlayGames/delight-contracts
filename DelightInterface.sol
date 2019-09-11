pragma solidity ^0.5.9;

interface DelightInterface {
	
	// 건물 정보
	struct Building {
		uint kind;
		uint level;
		uint col;
		uint row;
		address owner;
		uint buildTime;
	}
	
	// 부대 정보
	struct Army {
		uint kind;
		uint unitCount;
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