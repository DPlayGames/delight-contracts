pragma solidity ^0.5.9;

interface DelightBuildingManagerInterface {
	
	// 이벤트들
	event Build(uint indexed buildingId);
	event UpgradeHQ(uint indexed buildingId);
	event DestroyBuilding(uint indexed buildingId);
	
	// 건물 정보
	struct Building {
		uint kind;
		uint level;
		uint col;
		uint row;
		address owner;
		uint buildTime;
	}
	
	// 건물의 총 개수를 반환합니다.
	function getBuildingCount() view external returns (uint);
	
	// 건물의 정보를 반환합니다.
	function getBuildingInfo(uint buildingId) view external returns (
		uint kind,
		uint level,
		uint col,
		uint row,
		address owner,
		uint buildTime
	);
	
	// 특정 위치의 건물 ID를 반환합니다.
	function getPositionBuildingId(uint col, uint row) view external returns (uint);
	
	// 특정 위치의 건물의 주인을 반환합니다.
	function getPositionBuildingOwner(uint col, uint row) view external returns (address);
}