pragma solidity ^0.5.9;

import "./DelightKnightItemInterface.sol";
import "./Standard/ERC721.sol";
import "./Standard/ERC721TokenReceiver.sol";
import "./Util/NetworkChecker.sol";
import "./Util/SafeMath.sol";

contract DelightKnightItem is DelightKnightItemInterface, ERC721, NetworkChecker {
	using SafeMath for uint;
	
	// The two addresses below are the addresses of the trusted smart contract, and don't need to be allowed.
	// 아래 두 주소는 신뢰하는 스마트 계약의 주소로 허락받을 필요가 없습니다.
	
	// Delight item manager's address
	// Delight 아이템 관리자 주소
	address public delightItemManager;
	
	// The address of DPlay trading post
	// DPlay 교역소 주소
	address public dplayTradingPost;
	
	constructor() NetworkChecker() public {
		
		if (network == Network.Mainnet) {
			//TODO
		}
		
		else if (network == Network.Kovan) {
			dplayTradingPost = address(0x5341392E21c464EE25294edeDf7ab96836bB9649);
		}
		
		else if (network == Network.Ropsten) {
			//TODO
		}
		
		else if (network == Network.Rinkeby) {
			//TODO
		}
		
		else {
			revert();
		}
		
		// The address 0 is not used.
		// 0번지는 사용하지 않습니다.
		items.push(KnightItem({
			hp			: 0,
			damage		: 0,
			buffHP		: 0,
			buffDamage	: 0
		}));
		
		// Hephaestus' Hammer
		createItem(KnightItem({
			hp			: 500,
			damage		: 250,
			buffHP		: 20,
			buffDamage	: 10
		}));
		
		// Greek Shield
		createItem(KnightItem({
			hp			: 1000,
			damage		: 170,
			buffHP		: 50,
			buffDamage	: 0
		}));
		
		// Undead's Sword
		createItem(KnightItem({
			hp			: 200,
			damage		: 350,
			buffHP		: 0,
			buffDamage	: 40
		}));
		
		// Mace
		createItem(KnightItem({
			hp			: 400,
			damage		: 200,
			buffHP		: 30,
			buffDamage	: 30
		}));
		
		// Glass Sword
		createItem(KnightItem({
			hp			: 200,
			damage		: 1750,
			buffHP		: 30,
			buffDamage	: 0
		}));
		
		// Slaughter
		createItem(KnightItem({
			hp			: 500,
			damage		: 0,
			buffHP		: 35,
			buffDamage	: 35
		}));
		
		// Hel's Scythe
		createItem(KnightItem({
			hp			: 0,
			damage		: 3000,
			buffHP		: 0,
			buffDamage	: 0
		}));
		
		// Laevateinn
		createItem(KnightItem({
			hp			: 1000,
			damage		: 500,
			buffHP		: 30,
			buffDamage	: 40
		}));
		
		// Crescent Spear
		createItem(KnightItem({
			hp			: 500,
			damage		: 1000,
			buffHP		: 50,
			buffDamage	: 30
		}));
		
		// Traitor Hero's Straight Sword
		createItem(KnightItem({
			hp			: 1000,
			damage		: 750,
			buffHP		: 15,
			buffDamage	: 60
		}));
		
		// Rapier
		createItem(KnightItem({
			hp			: 0,
			damage		: 1250,
			buffHP		: 0,
			buffDamage	: 110
		}));
		
		// Hermes' Staff
		createItem(KnightItem({
			hp			: 2100,
			damage		: 0,
			buffHP		: 210,
			buffDamage	: 0
		}));
		
		// Ymir's Fragment
		createItem(KnightItem({
			hp			: 1100,
			damage		: 575,
			buffHP		: 110,
			buffDamage	: 55
		}));
		
		// Bone Axe of Typhon
		createItem(KnightItem({
			hp			: 1150,
			damage		: 600,
			buffHP		: 115,
			buffDamage	: 57
		}));
		
		// Hector's Sword
		createItem(KnightItem({
			hp			: 1000,
			damage		: 730,
			buffHP		: 0,
			buffDamage	: 120
		}));
		
		// Tyr's Claw
		createItem(KnightItem({
			hp			: 200,
			damage		: 3400,
			buffHP		: 125,
			buffDamage	: 0
		}));
		
		// Jormungand's Canine
		createItem(KnightItem({
			hp			: 1300,
			damage		: 100,
			buffHP		: 130,
			buffDamage	: 77
		}));
		
		// Kronos' Two Handed Axe
		createItem(KnightItem({
			hp			: 100,
			damage		: 700,
			buffHP		: 195,
			buffDamage	: 0
		}));
		
		// Titan Sword
		createItem(KnightItem({
			hp			: 1400,
			damage		: 725,
			buffHP		: 140,
			buffDamage	: 70
		}));
		
		// Sword of Valhalla
		createItem(KnightItem({
			hp			: 200,
			damage		: 750,
			buffHP		: 20,
			buffDamage	: 150
		}));
		
		// Ancient God's Sword
		createItem(KnightItem({
			hp			: 1000,
			damage		: 775,
			buffHP		: 160,
			buffDamage	: 75
		}));
		
		// Triaina
		createItem(KnightItem({
			hp			: 500,
			damage		: 1400,
			buffHP		: 100,
			buffDamage	: 100
		}));
		
		// Helios' Sun Hammer
		createItem(KnightItem({
			hp			: 2500,
			damage		: 200,
			buffHP		: 220,
			buffDamage	: 20
		}));
		
		// Heimdallr's Sword
		createItem(KnightItem({
			hp			: 1650,
			damage		: 4200,
			buffHP		: 165,
			buffDamage	: 10
		}));
		
		// Gungnir
		createItem(KnightItem({
			hp			: 3000,
			damage		: 3520,
			buffHP		: 20,
			buffDamage	: 85
		}));
		
		// Mistilteinn
		createItem(KnightItem({
			hp			: 250,
			damage		: 6100,
			buffHP		: 175,
			buffDamage	: 0
		}));
		
		// Song of the Cherry Blossoms
		createItem(KnightItem({
			hp			: 1800,
			damage		: 925,
			buffHP		: 90,
			buffDamage	: 270
		}));
		
		// Oceanus' Axe
		createItem(KnightItem({
			hp			: 2800,
			damage		: 450,
			buffHP		: 400,
			buffDamage	: 0
		}));
		
		// Tyrfing
		createItem(KnightItem({
			hp			: 1900,
			damage		: 975,
			buffHP		: 300,
			buffDamage	: 50
		}));
		
		// Skull
		createItem(KnightItem({
			hp			: 2000,
			damage		: 1000,
			buffHP		: 200,
			buffDamage	: 100
		}));
	}
	
	function setDelightItemManagerOnce(address addr) external {
		
		// The address has to be empty.
		// 비어있는 주소인 경우에만
		require(delightItemManager == address(0));
		
		delightItemManager = addr;
	}
	
	// Knight item information
	// 기사 아이템 정보
	struct KnightItem {
		uint hp;
		uint damage;
		uint buffHP;
		uint buffDamage;
	}
	
	KnightItem[] private items;
	
	mapping(uint => address) public itemIdToOwner;
	mapping(address => uint[]) public ownerToItemIds;
	mapping(uint => uint) internal itemIdToItemIdsIndex;
	mapping(uint => address) private itemIdToApproved;
	mapping(address => mapping(address => bool)) private ownerToOperatorToIsApprovedForAll;
	
	// 아이템을 생성합니다.
	function createItem(KnightItem memory item) private {
		
		uint itemId = items.push(item).sub(1);
		
		itemIdToOwner[itemId] = msg.sender;
		itemIdToItemIdsIndex[itemId] = ownerToItemIds[msg.sender].push(itemId).sub(1);
		
		emit Transfer(address(0), msg.sender, itemId);
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
			msg.sender == delightItemManager ||
			msg.sender == dplayTradingPost
		);
		_;
	}
	
	//ERC721: Gets the number of items.
	//ERC721: 아이템의 개수를 가져옵니다.
	function balanceOf(address owner) view public returns (uint) {
		return ownerToItemIds[owner].length;
	}
	
	//ERC721: Gets the wallet address of the item owner.
	//ERC721: 아이템 소유주의 지갑 주소를 가져옵니다.
	function ownerOf(uint itemId) view public returns (address) {
		return itemIdToOwner[itemId];
	}
	
	//ERC721: If a smart contract is the receiver of the item, executes the function onERC721Received.
	//ERC721: 아이템을 받는 대상이 스마트 계약인 경우, onERC721Received 함수를 실행합니다.
	function safeTransferFrom(address from, address to, uint itemId, bytes memory data) public {
		
		transferFrom(from, to, itemId);
		
		// Checks if the given address is a smart contract.
		// 주어진 주소가 스마트 계약인지 확인합니다.
		uint32 size;
		assembly { size := extcodesize(to) }
		if (size > 0) {
			// ERC721TokenReceiver
			require(ERC721TokenReceiver(to).onERC721Received(msg.sender, from, itemId, data) == 0x150b7a02);
		}
	}
	
	//ERC721: If a smart contract is the receiver of the item, executes the function onERC721Received.
	//ERC721: 아이템을 받는 대상이 스마트 계약인 경우, onERC721Received 함수를 실행합니다.
	function safeTransferFrom(address from, address to, uint itemId) external {
		safeTransferFrom(from, to, itemId, "");
	}
	
	//ERC721: Transfers the item.
	//ERC721: 아이템을 이전합니다.
	function transferFrom(address from, address to, uint itemId) onlyApprovedOf(itemId) public {
		
		require(from == ownerOf(itemId));
		require(to != ownerOf(itemId));
		
		// Delete trading rights.
		// 거래 권한 제거
		delete itemIdToApproved[itemId];
		emit Approval(from, address(0), itemId);
		
		// Deletes the item from the original owner.
		// 기존 소유주로부터 아이템 제거
		uint index = itemIdToItemIdsIndex[itemId];
		uint lastIndex = balanceOf(from).sub(1);
		
		uint lastItemId = ownerToItemIds[from][lastIndex];
		ownerToItemIds[from][index] = lastItemId;
		
		delete ownerToItemIds[from][lastIndex];
		ownerToItemIds[from].length -= 1;
		
		itemIdToItemIdsIndex[lastItemId] = index;
		
		// Transfers the item.
		// 아이템 이전
		itemIdToOwner[itemId] = to;
		itemIdToItemIdsIndex[itemId] = ownerToItemIds[to].push(itemId).sub(1);
		
		emit Transfer(from, to, itemId);
	}
	
	//ERC721: Approves trading to a given contract.
	//ERC721: 특정 계약에 거래 권한을 부여합니다.
	function approve(address approved, uint itemId) onlyOwnerOf(itemId) external {
		
		address owner = ownerOf(itemId);
		
		require(approved != owner);
		
		itemIdToApproved[itemId] = approved;
		emit Approval(owner, approved, itemId);
	}
	
	//ERC721: Approves or disapproves trading rights to the operator.
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
	
	//ERC721: Gets the approved wallet address.
	//ERC721: 아이템 거래 권한이 승인된 지갑 주소를 가져옵니다.
	function getApproved(uint itemId) public view returns (address) {
		return itemIdToApproved[itemId];
	}
	
	//ERC721: 오퍼레이터가 모든 토큰에 대한 거래 권한을 가지고 있는지 확인합니다.
	function isApprovedForAll(address owner, address operator) view public returns (bool) {
		return ownerToOperatorToIsApprovedForAll[owner][operator] == true ||
			// Delight와 DPlay 교역소는 모든 토큰을 전송할 수 있습니다.
			msg.sender == delightItemManager ||
			msg.sender == dplayTradingPost;
	}
	
	// Returns the number of items.
	// 아이템의 개수를 반환합니다.
	function getItemCount() public view returns (uint) {
		return items.length;
	}
	
	// Returns the information of an item.
	// 아이템의 정보를 반환합니다.
	function getItemInfo(uint itemId) external view returns (
		uint hp,
		uint damage,
		uint buffHP,
		uint buffDamage
	) {
		
		KnightItem memory item = items[itemId];
		
		return (
			item.hp,
			item.damage,
			item.buffHP,
			item.buffDamage
		);
	}
	
	// Returns the HP given to the knight of the item.
	// 아이템의 기사에게 부여하는 HP를 반환합니다.
	function getItemHP(uint itemId) external view returns (uint) {
		return items[itemId].hp;
	}
	
	// Returns the damage given to the knight of the item.
	// 아이템의 기사에게 부여하는 데미지를 반환합니다.
	function getItemDamage(uint itemId) external view returns (uint) {
		return items[itemId].damage;
	}
	
	// Returns the buff HP of an item.
	// 아이템의 버프 HP를 반환합니다.
	function getItemBuffHP(uint itemId) external view returns (uint) {
		return items[itemId].buffHP;
	}
	
	// Returns the buff damage of an item.
	// 아이템의 버프 데미지를 반환합니다.
	function getItemBuffDamage(uint itemId) external view returns (uint) {
		return items[itemId].buffDamage;
	}
	
	// Gets the knight IDs of the owner.
	// 소유주의 기사 ID들을 가져옵니다.
	function getOwnerItemIds(address owner) external view returns (uint[] memory) {
		
		uint itemCount = 0;
		
		for (uint i = 0; i < getItemCount(); i += 1) {
			if (ownerOf(i) == owner) {
				itemCount += 1;
			}
		}
		
		uint[] memory itemIds = new uint[](itemCount);
		uint j = 0;
		
		for (uint i = 0; i < getItemCount(); i += 1) {
			if (ownerOf(i) == owner) {
				itemIds[j] = i;
				j += 1;
			}
		}
		
		return itemIds;
	}
}
