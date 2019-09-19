pragma solidity ^0.5.9;

interface DelightTradingPostInterface {
	
	// 자원 판매 ID들을 가져옵니다.
	function getResourceSaleIds() view external returns (uint[] memory);
	
	// 아이템 판매 ID들을 가져옵니다.
	function getItemSaleIds() view external returns (uint[] memory);
	
	// 기사 아이템 판매 ID들을 가져옵니다.
	function getKnightItemSaleIds() view external returns (uint[] memory);
}
