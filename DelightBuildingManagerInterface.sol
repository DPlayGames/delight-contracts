pragma solidity ^0.5.9;

interface DelightBuildingManagerInterface {
	
	// Events
	// 이벤트들
	event Build(uint indexed buildingId);
	event UpgradeHQ(uint indexed buildingId);
	event DestroyBuilding(uint indexed buildingId);
	
	// Building information
	// 건물 정보
	struct Building {
		uint kind;
		uint level;
		uint col;
		uint row;
		address owner;
		uint buildTime;
	}
	
	// Returns the total number of buildings
	// 건물의 총 개수를 반환합니다.
	function getBuildingCount() view external returns (uint);
	
	// Returns the information of the building.
	// 건물의 정보를 반환합니다.
	function getBuildingInfo(uint buildingId) view external returns (
		uint kind,
		uint level,
		uint col,
		uint row,
		address owner,
		uint buildTime
	);
	
	// Returns the Building IDs on a given tile.
	// 특정 위치의 건물 ID를 반환합니다.
	function getPositionBuildingId(uint col, uint row) view external returns (uint);
	
	// Returns the owner of the building on a given tile.
	// 특정 위치의 건물의 주인을 반환합니다.
	function getPositionBuildingOwner(uint col, uint row) view external returns (address);
	
	// 특정 위치의 건물의 버프 HP를 반환합니다.
	function getBuildingBuffHP(uint col, uint row) view external returns (uint);
	
	// 특정 위치의 건물의 버프 데미지를 반환합니다.
	function getBuildingBuffDamage(uint col, uint row) view external returns (uint);
}
