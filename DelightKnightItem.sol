pragma solidity ^0.5.9;

import "./Standard/ERC721.sol";
import "./Standard/ERC721TokenReceiver.sol";
import "./Util/SafeMath.sol";

contract DelightKnightItem is ERC721 {
	using SafeMath for uint;
	
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