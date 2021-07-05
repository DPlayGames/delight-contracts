pragma solidity ^0.5.9;

interface DelightKnightItemInterface {
	
    event Transfer(address indexed from, address indexed to, uint indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    
    function balanceOf(address owner) external view returns (uint);
    function ownerOf(uint tokenId) external view returns (address);
    function safeTransferFrom(address from, address to, uint tokenId, bytes calldata data) external;
    function safeTransferFrom(address from, address to, uint tokenId) external;
    function transferFrom(address from, address to, uint tokenId) external;
    function approve(address approved, uint tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(uint tokenId) external view returns (address);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    
    // Returns the number of items.
    // 아이템의 개수를 반환합니다.
	function getItemCount() external view returns (uint);
	
	// Returns the number of items.
	// 아이템의 정보를 반환합니다.
	function getItemInfo(uint itemId) external view returns (
		uint hp,
		uint damage,
		uint buffHP,
		uint buffDamage
	);
	
	// Returns the HP given to the knight of the item.
	// 아이템의 기사에게 부여하는 HP를 반환합니다.
	function getItemHP(uint itemId) external view returns (uint);
	
	// Returns the damage given to the knight of the item.
	// 아이템의 기사에게 부여하는 데미지를 반환합니다.
	function getItemDamage(uint itemId) external view returns (uint);
	
	// Returns the buff HP of the item.
	// 아이템의 버프 HP를 반환합니다.
	function getItemBuffHP(uint itemId) external view returns (uint);
	
	// Returns the buff damage of the item.
	// 아이템의 버프 데미지를 반환합니다.
	function getItemBuffDamage(uint itemId) external view returns (uint);
	
	// Gets the knight IDs of the owner.
	// 소유주의 기사 ID들을 가져옵니다.
	function getOwnerItemIds(address owner) external view returns (uint[] memory);
}
