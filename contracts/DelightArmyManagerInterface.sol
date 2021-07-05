pragma solidity ^0.5.9;

interface DelightArmyManagerInterface {
	
	// Events
	// 이벤트들
	event CreateArmy(uint indexed armyId);
	event AttachItem(uint indexed armyId, uint indexed newArmyId);
	event AttachKnightItem(uint indexed armyId);
	event MoveArmy(uint indexed armyId);
	event MergeArmy(uint indexed fromArmyId, uint indexed toArmyId, uint unitCount);
	event DeadUnits(uint indexed armyId);
	
	// Army information
	// 부대 정보
	struct Army {
		uint unitKind;
		uint unitCount;
		uint knightItemId;
		uint col;
		uint row;
		address owner;
		uint createTime;
	}
	
	// Reward
	// 보상
	struct Reward {
		uint wood;
		uint stone;
		uint iron;
		uint ducat;
		uint knightItemId;
	}
	
	// Returns the total number of armies
	// 부대의 총 개수를 반환합니다.
	function getArmyCount() view external returns (uint);
	
	// Returns the information of an army
	// 부대의 정보를 반환합니다.
	function getArmyInfo(uint armyId) view external returns (
		uint unitKind,
		uint unitCount,
		uint knightItemId,
		uint col,
		uint row,
		address owner,
		uint createTime
	);
	
	// 보상 정보를 반환합니다.
	function getRewardInfo(uint battleId) view external returns (
		uint wood,
		uint stone,
		uint iron,
		uint ducat
	);
	
	// Gets the IDs of the armies located in a specific tile.
	// 특정 위치에 존재하는 부대의 ID들을 가져옵니다.
	function getPositionArmyIds(uint col, uint row) view external returns (uint[] memory);
	
	// Gets the owners of the armies located in a specific tile.
	// 특정 위치에 존재하는 부대의 소유주를 가져옵니다.
	function getPositionOwner(uint col, uint row) view external returns (address);
}
