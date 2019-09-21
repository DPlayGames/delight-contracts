pragma solidity ^0.5.9;

interface DPlayTradingPostInterface {
	
	// Events
	// 이벤트
	event SellItem(uint saleId, uint price, address[] itemAddresses, uint[] itemAmounts, string description, uint createTime);
	event SellUniqueItem(uint saleId, uint price, address[] uniqueItemAddresses, uint[] uniqueItemIds, string description, uint createTime);
	event CancelItemSale(uint indexed saleId);
	event CancelUniqueItemSale(uint indexed saleId);
	event BuyItemSale(uint indexed saleId, address indexed buyer);
	event BuyUniqueItemSale(uint indexed saleId, address indexed buyer);
	
	// Item sale info
	// 아이템 판매 정보
	struct ItemSale {
		address		seller;
		address[]	itemAddresses;
		uint[]		itemAmounts;
		uint		price;
		string		description;
		uint		createTime;
	}
	
	// Unique item sale info
	// 유니크 아이템 판매 정보
	struct UniqueItemSale {
		address		seller;
		address[]	itemAddresses;
		uint[]		itemIds;
		uint		price;
		string		description;
		uint		createTime;
	}
	
	// Returns the number of item sales.
	// 아이템 판매 횟수를 반환합니다.
	function getItemSaleCount() external view returns (uint);
	
	// Returns the number of unique item sales.
	// 유니크 아이템 판매 횟수를 반환합니다.
	function getUniqueItemSaleCount() external view returns (uint);
	
	// Sells items.
	// 아이템을 판매합니다.
	function sellItem(
		address[] calldata	itemAddresses,
		uint[] calldata		itemAmounts,
		uint				price,
		string calldata		description
	) external returns (uint);
	
	// Sells unique items.
	// 유니크 아이템을 판매합니다.
	function sellUniqueItem(
		address[] calldata	itemAddresses,
		uint[] calldata		itemIds,
		uint				price,
		string calldata		description
	) external returns (uint);
	
	// Checks if the given address is the item seller.
	// 특정 주소가 아이템 판매자인지 확인합니다.
	function checkIsItemSeller(address addr, uint saleId) external view returns (bool);
	
	// Checks if the given address is the unique item seller.
	// 특정 주소가 유니크 아이템 판매자인지 확인합니다.
	function checkIsUniqueItemSeller(address addr, uint saleId) external view returns (bool);
	
	// Gets the sale IDs of the items sold by the given seller.
	// 특정 판매자가 판매중인 아이템 판매 ID들을 가져옵니다.
	function getItemSaleIds(address seller) external view returns (uint[] memory);
	
	// Gets the sale IDs of the unique items sold by the given seller.
	// 특정 판매자가 판매중인 유니크 아이템 판매 ID들을 가져옵니다.
	function getUniqueItemSaleIds(address seller) external view returns (uint[] memory);
	
	// Returns item sale info.
	// 아이템 판매 정보를 반환합니다.
	function getItemSaleInfo(uint saleId) external view returns (
		address seller,
		address[] memory itemAddresses,
		uint[] memory itemAmounts,
		uint price,
		string memory description,
		uint createTime
	);
	
	// Returns unique item sale info.
	// 유니크 아이템 판매 정보를 반환합니다.
	function getUniqueItemSaleInfo(uint saleId) external view returns (
		address seller,
		address[] memory itemAddresses,
		uint[] memory itemIds,
		uint price,
		string memory description,
		uint createTime
	);
	
	// Cancels an item sale.
	// 아이템 판매를 취소합니다.
	function cancelItemSale(uint saleId) external;
	
	// Cancels a unique item sale.
	// 유니크 아이템 판매를 취소합니다.
	function cancelUniqueItemSale(uint saleId) external;
	
	// Buys items.
	// 아이템을 구매합니다.
	function buyItem(uint saleId) external;
	
	// Buys unique items.
	// 유니크 아이템을 구매합니다.
	function buyUniqueItem(uint saleId) external;
}
