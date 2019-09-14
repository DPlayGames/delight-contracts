pragma solidity ^0.5.9;

import "./DelightManager.sol";
import "./DelightItem.sol";
import "./DelightKnightItem.sol";
import "./Util/SafeMath.sol";

contract DelightItemManager is DelightManager {
	using SafeMath for uint;
	
	// Delight 부대 관리자 주소
	address public delightArmyManager;
	
	function setDelightArmyManagerOnce(address addr) external {
		
		// 비어있는 주소인 경우에만
		require(delightArmyManager == address(0));
		
		delightArmyManager = addr;
	}
	
	// Sender가 Delight일때만 실행
	modifier onlyDelight() {
		require(
			msg.sender == delight ||
			msg.sender == delightArmyManager
		);
		_;
	}
	
	DelightItem private axe;
	DelightItem private spear;
	DelightItem private shield;
	DelightItem private hood;
	DelightItem private crossbow;
	DelightItem private ballista;
	DelightItem private catapult;
	DelightItem private camel;
	DelightItem private elephant;
	
	function getItemContract(uint kind) view private returns (DelightItem) {
		if (kind == ITEM_AXE) {
			return axe;
		} else if (kind == ITEM_SPEAR) {
			return spear;
		} else if (kind == ITEM_SHIELD) {
			return shield;
		} else if (kind == ITEM_HOOD) {
			return hood;
		} else if (kind == ITEM_CROSSBOW) {
			return crossbow;
		} else if (kind == ITEM_BALLISTA) {
			return ballista;
		} else if (kind == ITEM_CATAPULT) {
			return catapult;
		} else if (kind == ITEM_CAMEL) {
			return camel;
		} else if (kind == ITEM_ELEPHANT) {
			return elephant;
		}
	}
	
	DelightKnightItem private knightItem;
	
	constructor() DelightManager() public {
		
		if (network == Network.Mainnet) {
			//TODO
		}
		
		else if (network == Network.Kovan) {
			//TODO
			
			// 아이템
			axe			= DelightItem(0x8c187Fa9ec4cc00A102E87380a9527A35fe047D0);
			ballista	= DelightItem(0x5bfF20BdA2D7f564A0D8AC1eC9578fc319a778EC);
			camel		= DelightItem(0x282E3D0562106a1c4DA99B8b011129fb7E20a91e);
			catapult	= DelightItem(0x9C6e4f3e0E018D5f6Dca4031d549E897eAdE550d);
			crossbow	= DelightItem(0xC27E3a48ee6a1632DD62e385D9CbfCCe4fd22cF6);
			elephant	= DelightItem(0xCb9B9a16884470775390C03aCa68722D2671F69f);
			hood		= DelightItem(0x60D9e720840e6844DA04BD9Ebf42e63FA6EDeF97);
			shield		= DelightItem(0xe8f92B5eB1F67441f85956793793A9471c3f5BE0);
			spear		= DelightItem(0x9891c504Bc4F557c0B90BB51B3F21F57705e3db7);
			
			// 기사 아이템
			knightItem	= DelightKnightItem(0x0c3ad341A711ECC43Ce5f18f0337F20A5861a60B);
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
	}
	
	// 아이템을 생성합니다.
	function createItem(address owner, uint kind, uint count) onlyDelight external {
		
		uint materialWood = info.getItemMaterialWood(kind).mul(count);
		uint materialStone = info.getItemMaterialStone(kind).mul(count);
		uint materialIron = info.getItemMaterialIron(kind).mul(count);
		uint materialDucat = info.getItemMaterialDucat(kind).mul(count);
		
		// 아이템을 생산하는데 필요한 자원이 충분한지 확인합니다.
		require(
			wood.balanceOf(owner) >= materialWood &&
			stone.balanceOf(owner) >= materialStone &&
			iron.balanceOf(owner) >= materialIron &&
			ducat.balanceOf(owner) >= materialDucat
		);
		
		DelightItem itemContract = getItemContract(kind);
		
		// 아이템을 생성합니다.
		itemContract.assemble(owner, count);
		
		// 자원을 Delight로 이전합니다.
		wood.transferFrom(owner, delight, materialWood);
		stone.transferFrom(owner, delight, materialStone);
		iron.transferFrom(owner, delight, materialIron);
		ducat.transferFrom(owner, delight, materialDucat);
	}
	
	// 부대에 아이템을 장착합니다.
	function attachItem(address owner, uint kind, uint count) onlyDelight external {
		
		DelightItem itemContract = getItemContract(kind);
		
		// 아이템 수가 충분한지 확인합니다.
		require(itemContract.balanceOf(owner) >= count);
		
		// 아이템을 Delight로 이전합니다.
		itemContract.transferFrom(owner, address(this), count);
	}
	
	// 아이템을 분해합니다.
	function disassembleItem(uint kind, uint count) onlyDelight external returns (
		uint wood,
		uint stone,
		uint iron,
		uint ducat
	) {
		
		DelightItem itemContract = getItemContract(kind);
		
		// 아이템을 분해합니다.
		itemContract.disassemble(count);
		
		// 재료를 반환합니다.
		return (
			info.getItemMaterialWood(kind).mul(count),
			info.getItemMaterialStone(kind).mul(count),
			info.getItemMaterialIron(kind).mul(count),
			info.getItemMaterialDucat(kind).mul(count)
		);
	}
	
	// 기사에 아이템을 장착합니다.
	function attachKnightItem(address owner, uint itemId) onlyDelight external {
		
		// 아이템을 소유하고 있는지 확인합니다.
		require(knightItem.ownerOf(itemId) == owner);
		
		// 아이템을 Delight로 이전합니다.
		knightItem.transferFrom(owner, address(this), itemId);
	}
	
	// 기사 아이템을 이전합니다.
	function transferKnightItem(address to, uint itemId) onlyDelight external {
		
		// 아이템을 소유하고 있는지 확인합니다.
		require(knightItem.ownerOf(itemId) == address(this));
		
		// 아이템을 이전합니다.
		knightItem.transferFrom(address(this), to, itemId);
	}
}