pragma solidity ^0.5.9;

interface DelightOwnerInterface {
	
	// Gets the record IDs of the owner.
	// 소유주의 기록 ID들을 가져옵니다.
	function getRecordIds(address owner) view external returns (uint[] memory);
	
	// Gets the building IDs of the owner.
	// 소유주의 건물 ID들을 가져옵니다.
	function getBuildingIds(address owner) view external returns (uint[] memory);
	
	// Gets the army IDs of the owner.
	// 소유주의 부대 ID들을 가져옵니다.
	function getArmyIds(address owner) view external returns (uint[] memory);
	
	// 전체 맵의 건물 소유주 목록을 반환합니다.
	function getMapBuildingOwners() view external returns (address[] memory);
	
	// 전체 맵의 부대 소유주 목록을 반환합니다.
	function getMapArmyOwners() view external returns (address[] memory);
}
