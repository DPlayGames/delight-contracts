pragma solidity ^0.5.9;

import "./Standard/ERC721.sol";
import "./Standard/ERC721TokenReceiver.sol";
import "./Util/SafeMath.sol";

contract DelightKnightItem is ERC721 {
	using SafeMath for uint;
	
	// 기사 아이템 정보
	struct KnightItem {
		uint hp;
		uint damage;
		uint movableDistance;
		uint attackableDistance;
		uint buffHP;
		uint buffDamage;
	}
	
	KnightItem[] private items;
	
	mapping(uint => address) public itemIdToOwner;
	mapping(address => uint[]) public ownerToItemIds;
	mapping(uint => uint) internal itemIdToItemIdsIndex;
	mapping(uint => address) private itemIdToApproved;
	mapping(address => mapping(address => bool)) private ownerToOperatorToIsApprovedForAll;
	
	// Delight 주소
	address public delight;
	
	// The address of DPlay trading post
	// DPlay 교역소 주소
	address public dplayTradingPost;
	
	// 아이템을 생성합니다.
	function createItem(KnightItem memory item) private {
		
		uint itemId = items.push(item).sub(1);
		
		itemIdToOwner[itemId] = msg.sender;
		itemIdToItemIdsIndex[itemId] = ownerToItemIds[msg.sender].push(itemId).sub(1);
		
		emit Transfer(address(0x0), msg.sender, itemId);
	}
	
	constructor() public {
		
		// 0번지는 사용하지 않습니다.
		items.push(KnightItem({
			hp					: 0,
			damage				: 0,
			movableDistance		: 0,
			attackableDistance	: 0,
			buffHP				: 0,
			buffDamage			: 0
		}));
		
		// Mistilteinn
		createItem(KnightItem({
			hp					: 1,
			damage				: 1,
			movableDistance		: 1,
			attackableDistance	: 1,
			buffHP				: 1,
			buffDamage			: 1
		}));
		
		// Gungnir
		createItem(KnightItem({
			hp					: 2,
			damage				: 2,
			movableDistance		: 2,
			attackableDistance	: 2,
			buffHP				: 2,
			buffDamage			: 2
		}));
		
		// Traitor Hero's Straight Sword
		createItem(KnightItem({
			hp					: 3,
			damage				: 3,
			movableDistance		: 3,
			attackableDistance	: 3,
			buffHP				: 3,
			buffDamage			: 3
		}));
		
		// Sword of Valhalla
		createItem(KnightItem({
			hp					: 4,
			damage				: 4,
			movableDistance		: 4,
			attackableDistance	: 4,
			buffHP				: 4,
			buffDamage			: 4
		}));
		
		// Ymir's Fragment
		createItem(KnightItem({
			hp					: 5,
			damage				: 5,
			movableDistance		: 5,
			attackableDistance	: 5,
			buffHP				: 5,
			buffDamage			: 5
		}));
		
		// Hel's Scythe
		createItem(KnightItem({
			hp					: 6,
			damage				: 6,
			movableDistance		: 6,
			attackableDistance	: 6,
			buffHP				: 6,
			buffDamage			: 6
		}));
		
		// Skull
		createItem(KnightItem({
			hp					: 7,
			damage				: 7,
			movableDistance		: 7,
			attackableDistance	: 7,
			buffHP				: 7,
			buffDamage			: 7
		}));
		
		// Laevateinn
		createItem(KnightItem({
			hp					: 7,
			damage				: 7,
			movableDistance		: 7,
			attackableDistance	: 7,
			buffHP				: 7,
			buffDamage			: 7
		}));
		
		// Jormungand's Canine
		createItem(KnightItem({
			hp					: 7,
			damage				: 7,
			movableDistance		: 7,
			attackableDistance	: 7,
			buffHP				: 7,
			buffDamage			: 7
		}));
		
		// Tyrfing
		createItem(KnightItem({
			hp					: 7,
			damage				: 7,
			movableDistance		: 7,
			attackableDistance	: 7,
			buffHP				: 7,
			buffDamage			: 7
		}));
		
		// Heimdallr's Sword
		createItem(KnightItem({
			hp					: 7,
			damage				: 7,
			movableDistance		: 7,
			attackableDistance	: 7,
			buffHP				: 7,
			buffDamage			: 7
		}));
		
		// Rapier
		createItem(KnightItem({
			hp					: 7,
			damage				: 7,
			movableDistance		: 7,
			attackableDistance	: 7,
			buffHP				: 7,
			buffDamage			: 7
		}));
		
		// Song of the Cherry Blossoms
		createItem(KnightItem({
			hp					: 7,
			damage				: 7,
			movableDistance		: 7,
			attackableDistance	: 7,
			buffHP				: 7,
			buffDamage			: 7
		}));
		
		// Ancient God's Sword
		createItem(KnightItem({
			hp					: 7,
			damage				: 7,
			movableDistance		: 7,
			attackableDistance	: 7,
			buffHP				: 7,
			buffDamage			: 7
		}));
		
		// Undead's Sword
		createItem(KnightItem({
			hp					: 7,
			damage				: 7,
			movableDistance		: 7,
			attackableDistance	: 7,
			buffHP				: 7,
			buffDamage			: 7
		}));
		
		// Greek Shield
		createItem(KnightItem({
			hp					: 7,
			damage				: 7,
			movableDistance		: 7,
			attackableDistance	: 7,
			buffHP				: 7,
			buffDamage			: 7
		}));
		
		// Nymph's Spear
		createItem(KnightItem({
			hp					: 7,
			damage				: 7,
			movableDistance		: 7,
			attackableDistance	: 7,
			buffHP				: 7,
			buffDamage			: 7
		}));
		
		// Triaina
		createItem(KnightItem({
			hp					: 7,
			damage				: 7,
			movableDistance		: 7,
			attackableDistance	: 7,
			buffHP				: 7,
			buffDamage			: 7
		}));
		
		// Titan Sword
		createItem(KnightItem({
			hp					: 7,
			damage				: 7,
			movableDistance		: 7,
			attackableDistance	: 7,
			buffHP				: 7,
			buffDamage			: 7
		}));
		
		// Amazonian Dagger
		createItem(KnightItem({
			hp					: 7,
			damage				: 7,
			movableDistance		: 7,
			attackableDistance	: 7,
			buffHP				: 7,
			buffDamage			: 7
		}));
		
		// Hector's Sword
		createItem(KnightItem({
			hp					: 7,
			damage				: 7,
			movableDistance		: 7,
			attackableDistance	: 7,
			buffHP				: 7,
			buffDamage			: 7
		}));
		
		// Rhea's Scythe
		createItem(KnightItem({
			hp					: 7,
			damage				: 7,
			movableDistance		: 7,
			attackableDistance	: 7,
			buffHP				: 7,
			buffDamage			: 7
		}));
		
		// Tyr's Claw
		createItem(KnightItem({
			hp					: 7,
			damage				: 7,
			movableDistance		: 7,
			attackableDistance	: 7,
			buffHP				: 7,
			buffDamage			: 7
		}));
		
		// Kronos' Two Handed Axe
		createItem(KnightItem({
			hp					: 7,
			damage				: 7,
			movableDistance		: 7,
			attackableDistance	: 7,
			buffHP				: 7,
			buffDamage			: 7
		}));
		
		// Oceanus' Axe
		createItem(KnightItem({
			hp					: 7,
			damage				: 7,
			movableDistance		: 7,
			attackableDistance	: 7,
			buffHP				: 7,
			buffDamage			: 7
		}));
		
		// Bone Axe of Typhon
		createItem(KnightItem({
			hp					: 7,
			damage				: 7,
			movableDistance		: 7,
			attackableDistance	: 7,
			buffHP				: 7,
			buffDamage			: 7
		}));
		
		// Helios' Sun Hammer
		createItem(KnightItem({
			hp					: 7,
			damage				: 7,
			movableDistance		: 7,
			attackableDistance	: 7,
			buffHP				: 7,
			buffDamage			: 7
		}));
		
		// Mace
		createItem(KnightItem({
			hp					: 7,
			damage				: 7,
			movableDistance		: 7,
			attackableDistance	: 7,
			buffHP				: 7,
			buffDamage			: 7
		}));
		
		// Hermes' Staff
		createItem(KnightItem({
			hp					: 7,
			damage				: 7,
			movableDistance		: 7,
			attackableDistance	: 7,
			buffHP				: 7,
			buffDamage			: 7
		}));
		
		// Hephaestus' Hammer
		createItem(KnightItem({
			hp					: 7,
			damage				: 7,
			movableDistance		: 7,
			attackableDistance	: 7,
			buffHP				: 7,
			buffDamage			: 7
		}));
	}
	
	// 아이템의 개수를 반환합니다.
	function getItemCount() external view returns (uint) {
		return items.length;
	}
	
	// 아이템의 정보를 반환합니다.
	function getItemInfo(uint itemId) external view returns (
		uint hp,
		uint damage,
		uint movableDistance,
		uint attackableDistance,
		uint buffHP,
		uint buffDamage
	) {
		
		KnightItem memory item = items[itemId];
		
		return (
			item.hp,
			item.damage,
			item.movableDistance,
			item.attackableDistance,
			item.buffHP,
			item.buffDamage
		);
	}
	
	modifier onlyOwnerOf(uint itemId) {
		require(msg.sender == ownerOf(itemId));
		_;
	}
	
	modifier onlyApprovedOf(uint itemId) {
		require(
			msg.sender == ownerOf(itemId) ||
			msg.sender == getApproved(itemId) ||
			isApprovedForAll(ownerOf(itemId), msg.sender) == true ||
			msg.sender == delight ||
			msg.sender == dplayTradingPost
		);
		_;
	}
	
	//ERC721: 아이템의 개수를 가져옵니다.
	function balanceOf(address owner) view public returns (uint) {
		return ownerToItemIds[owner].length;
	}
	
	//ERC721: 아이템 소유주의 지갑 주소를 가져옵니다.
	function ownerOf(uint itemId) view public returns (address) {
		return itemIdToOwner[itemId];
	}
	
	//ERC721: 아이템을 받는 대상이 스마트 계약인 경우, onERC721Received 함수를 실행합니다.
	function safeTransferFrom(address from, address to, uint itemId, bytes memory data) payable public {
		
		transferFrom(from, to, itemId);
		
		// 주어진 주소가 스마트 계약인지 확인합니다.
		uint32 size;
		assembly { size := extcodesize(to) }
		if (size > 0) {
			// ERC721TokenReceiver
			require(ERC721TokenReceiver(to).onERC721Received(msg.sender, from, itemId, data) == 0x150b7a02);
		}
	}
	
	//ERC721: 아이템을 받는 대상이 스마트 계약인 경우, onERC721Received 함수를 실행합니다.
	function safeTransferFrom(address from, address to, uint itemId) payable external {
		safeTransferFrom(from, to, itemId, "");
	}
	
	//ERC721: 아이템을 이전합니다.
	function transferFrom(address from, address to, uint itemId) onlyApprovedOf(itemId) payable public {
		
		require(from == ownerOf(itemId));
		require(to != ownerOf(itemId));
		
		// 거래 권한 제거
		delete itemIdToApproved[itemId];
		emit Approval(from, address(0x0), itemId);
		
		// 기존 소유주로부터 아이템 제거
		uint index = itemIdToItemIdsIndex[itemId];
		uint lastIndex = balanceOf(from).sub(1);
		
		uint lastItemId = ownerToItemIds[from][lastIndex];
		ownerToItemIds[from][index] = lastItemId;
		
		delete ownerToItemIds[from][lastIndex];
		ownerToItemIds[from].length -= 1;
		
		itemIdToItemIdsIndex[lastItemId] = index;
		
		// 아이템 이전
		itemIdToOwner[itemId] = to;
		itemIdToItemIdsIndex[itemId] = ownerToItemIds[to].push(itemId).sub(1);
		
		emit Transfer(from, to, itemId);
	}
	
	//ERC721: 특정 계약에 거래 권한을 부여합니다.
	function approve(address approved, uint itemId) onlyOwnerOf(itemId) payable external {
		
		address owner = ownerOf(itemId);
		
		require(approved != owner);
		
		itemIdToApproved[itemId] = approved;
		emit Approval(owner, approved, itemId);
	}
	
	//ERC721: 오퍼레이터에게 거래 권한을 부여하거나 뺏습니다.
	function setApprovalForAll(address operator, bool isApproved) external {
		
		require(operator != msg.sender);
		
		if (isApproved == true) {
			ownerToOperatorToIsApprovedForAll[msg.sender][operator] = true;
		} else {
			delete ownerToOperatorToIsApprovedForAll[msg.sender][operator];
		}
		
		emit ApprovalForAll(msg.sender, operator, isApproved);
	}
	
	//ERC721: 아이템 거래 권한이 승인된 지갑 주소를 가져옵니다.
	function getApproved(uint itemId) public view returns (address) {
		return itemIdToApproved[itemId];
	}
	
	//ERC721: 오퍼레이터가 거래 권한을 가지고 있는지 확인합니다.
	function isApprovedForAll(address owner, address operator) view public returns (bool) {
		return ownerToOperatorToIsApprovedForAll[owner][operator] == true;
	}
}