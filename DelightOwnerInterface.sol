pragma solidity ^0.5.9;

interface DelightOwnerInterface {
	
	// 소유주의 기록 ID들을 가져옵니다.
	function getRecordIds(address owner) view external returns (uint[] memory);
	
	// 소유주의 건물 ID들을 가져옵니다.
	function getBuildingIds(address owner) view external returns (uint[] memory);
	
	// 소유주의 부대 ID들을 가져옵니다.
	function getArmyIds(address owner) view external returns (uint[] memory);
	
	// 소유주의 기사 ID들을 가져옵니다.
	function getKnightItemIds(address owner) view external returns (uint[] memory);
}