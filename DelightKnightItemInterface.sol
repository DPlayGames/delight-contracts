pragma solidity ^0.5.9;

interface DelightKnightItemInterface {
	
    event Transfer(address indexed _from, address indexed _to, uint indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    
    function balanceOf(address _owner) external view returns (uint);
    function ownerOf(uint _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint _tokenId, bytes calldata data) external payable;
    function safeTransferFrom(address _from, address _to, uint _tokenId) external payable;
    function transferFrom(address _from, address _to, uint _tokenId) external payable;
    function approve(address _approved, uint _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
    
    // 아이템의 개수를 반환합니다.
	function getItemCount() external view returns (uint);
	
	// 아이템의 정보를 반환합니다.
	function getItemInfo(uint itemId) external view returns (
		uint hp,
		uint damage,
		uint buffHP,
		uint buffDamage
	);
	
	// 아이템의 기사에게 부여하는 HP를 반환합니다.
	function getItemHP(uint itemId) external view returns (uint);
	
	// 아이템의 기사에게 부여하는 데미지를 반환합니다.
	function getItemDamage(uint itemId) external view returns (uint);
	
	// 아이템의 버프 HP를 반환합니다.
	function getItemBuffHP(uint itemId) external view returns (uint);
	
	// 아이템의 버프 데미지를 반환합니다.
	function getItemBuffDamage(uint itemId) external view returns (uint);
}