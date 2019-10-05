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
			axe			= DelightItem(0xfb42B7fEB1F8b9A3a5546bB6D89f919C9371B548);
			ballista	= DelightItem(0x4118cc91e488AC5bFa031De27AB650c45BF330Cd);
			camel		= DelightItem(0x1135ffaCCa15F820aB6e28A5F9070AB358981BEF);
			catapult	= DelightItem(0x9CB9142ab16833B753817ADc482EE45a4CbF9DE0);
			crossbow	= DelightItem(0xDFB07E448A8FeA5a933502D5CaAE1504b4763c98);
			elephant	= DelightItem(0x3Dff7cD183aE04c9e96D51E0a8d99ff27dE8F295);
			hood		= DelightItem(0x6310D8EE43783E885c79Be299D1BaB7012eD6510);
			shield		= DelightItem(0xd3Cc99A8AfDaBA24D18633a40a4Da8B9F5e88D2b);
			spear		= DelightItem(0x93B45F4Ca07702C1D06a0363d4B2080515B0E9b6);
			
			// Knight item
			// 기사 아이템
			knightItem	= DelightKnightItemInterface(0xC6F27ad6534eFEb0a6005Fc874A10922CBd9cA42);
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
