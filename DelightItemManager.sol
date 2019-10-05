pragma solidity ^0.5.9;

import "./DelightManager.sol";
import "./DelightItem.sol";
import "./DelightKnightItemInterface.sol";
import "./Util/SafeMath.sol";

contract DelightItemManager is DelightManager {
	using SafeMath for uint;
	
	// General items
	// 일반 아이템들
	DelightItem public axe;
	DelightItem public spear;
	DelightItem public shield;
	DelightItem public hood;
	DelightItem public crossbow;
	DelightItem public ballista;
	DelightItem public catapult;
	DelightItem public camel;
	DelightItem public elephant;
	
	// Knight item
	// 기사 아이템
	DelightKnightItemInterface private knightItem;
	
	// Delight army manager's address
	// Delight 부대 관리자 주소
	address private armyManager;
	
	constructor() DelightManager() public {
		
		if (network == Network.Mainnet) {
			//TODO
		}
		
		else if (network == Network.Kovan) {
			
			// Items
			// 아이템
			axe			= DelightItem(0xb3EDC95B47f3EDc4A59bED945415f1830A1699fd);
			ballista	= DelightItem(0xc63D963332123504df0385e3d408C281677786E8);
			camel		= DelightItem(0x3955e4586Ef25A4C4AeeBfe7641956699D393E2D);
			catapult	= DelightItem(0x752ae93FB4412E61A4f659dC4D3a4A991095497A);
			crossbow	= DelightItem(0xFf2Fb88c4196191a35017dA9Ffa7Cd9AFE5405d4);
			elephant	= DelightItem(0xaDC1D48c272cdd3eCe23BBE0eA10f25C142Ec3d5);
			hood		= DelightItem(0x41414898f3bDB6eaa54194235C7e085F39247562);
			shield		= DelightItem(0xbb5e43263Ec75fC1287798fa514A3D48e57644Ce);
			spear		= DelightItem(0x9549CbB4242f8903541e783051022ea4b6E98527);
			
			// Knight item
			// 기사 아이템
			knightItem	= DelightKnightItemInterface(0x7D48B2aF31d5F5607C1F819eF309b4bC907453b2);
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
	
	function setDelightArmyManagerOnce(address addr) external {
		
		// The address has to be empty
		// 비어있는 주소인 경우에만
		require(armyManager == address(0));
		
		armyManager = addr;
	}
	
	// Excutes only if the Sender is Delight.
	// Sender가 Delight일때만 실행
	modifier onlyDelight() {
		require(
			msg.sender == delight ||
			msg.sender == armyManager
		);
		_;
	}
	
	// Creates an item.
	// 아이템을 생성합니다.
	function createItem(address owner, uint kind, uint count) onlyDelight external {
		
		uint materialWood = info.getItemMaterialWood(kind).mul(count);
		uint materialStone = info.getItemMaterialStone(kind).mul(count);
		uint materialIron = info.getItemMaterialIron(kind).mul(count);
		uint materialDucat = info.getItemMaterialDucat(kind).mul(count);
		
		// Checks if there are enough resources to create the item.
		// 아이템을 생산하는데 필요한 자원이 충분한지 확인합니다.
		require(
			wood.balanceOf(owner) >= materialWood &&
			stone.balanceOf(owner) >= materialStone &&
			iron.balanceOf(owner) >= materialIron &&
			ducat.balanceOf(owner) >= materialDucat
		);
		
		DelightItem itemContract = getItemContract(kind);
		
		// Creates the item.
		// 아이템을 생성합니다.
		itemContract.assemble(owner, count);
		
		// Transfers the resources to Delight.
		// 자원을 Delight로 이전합니다.
		wood.transferFrom(owner, delight, materialWood);
		stone.transferFrom(owner, delight, materialStone);
		iron.transferFrom(owner, delight, materialIron);
		ducat.transferFrom(owner, delight, materialDucat);
	}
	
	// Equips items to an army.
	// 부대에 아이템을 장착합니다.
	function attachItem(address owner, uint kind, uint count) onlyDelight external {
		
		DelightItem itemContract = getItemContract(kind);
		
		// Checks if the number of items is enough.
		// 아이템 수가 충분한지 확인합니다.
		require(itemContract.balanceOf(owner) >= count);
		
		// Transfers the items to Delight.
		// 아이템을 Delight로 이전합니다.
		itemContract.transferFrom(owner, address(this), count);
	}
	
	// Dismantles an item.
	// 아이템을 분해합니다.
	function disassembleItem(uint kind, uint count) onlyDelight external {
		
		DelightItem itemContract = getItemContract(kind);
		
		// Dismantles the item.
		// 아이템을 분해합니다.
		itemContract.disassemble(count);
	}
	
	// Equips an item to a knight.
	// 기사에 아이템을 장착합니다.
	function attachKnightItem(address owner, uint itemId) onlyDelight external {
		
		// Checks if the item is owned.
		// 아이템을 소유하고 있는지 확인합니다.
		require(knightItem.ownerOf(itemId) == owner);
		
		// Transfers the item to Delight.
		// 아이템을 Delight로 이전합니다.
		knightItem.transferFrom(owner, address(this), itemId);
	}
	
	// Transfers a Knight item.
	// 기사 아이템을 이전합니다.
	function transferKnightItem(address to, uint itemId) onlyDelight external {
		
		// Checks if the item is owned.
		// 아이템을 소유하고 있는지 확인합니다.
		require(knightItem.ownerOf(itemId) == address(this));
		
		// Transfers the item.
		// 아이템을 이전합니다.
		knightItem.transferFrom(address(this), to, itemId);
	}
}
