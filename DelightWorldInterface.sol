pragma solidity ^0.5.9;

interface DelightWorldInterface {
	
	// 특정 위치에 존재하는 부대의 소유주를 가져옵니다.
	function getArmyOwnerByPosition(uint col, uint row) view external returns (address);
	
	// 건물을 짓습니다.
	function build(address owner, uint kind, uint col, uint row) external returns (uint);
	
	// 본부를 업그레이드합니다.
	function upgradeHQ(address owner, uint buildingId) external;
	
	// 건물에서 부대를 생산합니다.
	function createArmy(address owner, uint buildingId, uint unitCount) external returns (uint);
	
	// 아이템을 생성합니다.
	function createItem(address owner, uint kind, uint count) external returns (uint);
	
	// 부대에 아이템을 장착합니다.
	function attachItem(address owner, uint armyId, uint itemKind, uint unitCount) external;
	
	// 기사에 아이템을 장착합니다.
	function attachKnightItem(address owner, uint armyId, uint itemId) external;
}