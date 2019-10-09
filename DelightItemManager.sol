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
			
			// Items
			// 아이템
			axe			= DelightItem(0x619c0f7d056fa205cff28f5B091f64e3Dc127D2B);
			ballista	= DelightItem(0x3B49ABF046bBf43A2E778cB9EB74792B98F2969f);
			camel		= DelightItem(0x439F27Eb7352Ad797256A584316dc076A1eFCd78);
			catapult	= DelightItem(0x62F2eD69a7a3919A770a0E863d6D20f1fA93B368);
			crossbow	= DelightItem(0x7c4520E4572bef267b2d511aa155Ef5D7ED7DC2A);
			elephant	= DelightItem(0x57e48A94A7AdaF15e2dCF8521e9D29a714B0B45F);
			hood		= DelightItem(0x6B23D0A2aC73834c72A6d7b3cDF933D06A4b376A);
			shield		= DelightItem(0x41eA181C8aA43339675d036Fe09F4907c1c5b1D9);
			spear		= DelightItem(0x27F2C83Ad7dd2B538170491Bd657017486945c30);
			
			// Knight item
			// 기사 아이템
			knightItem	= DelightKnightItemInterface(0x79078dDe3b55d2dCAd5e5a4Aa84F08FB7d25368a);
		}
		
		else if (network == Network.Kovan) {
			
			// Items
			// 아이템
			axe			= DelightItem(0x7D783328f639BFaa205D1385f254181A4e72F8Fe);
			ballista	= DelightItem(0x9BDadCAf2ff7143b34C455093e0722b401490fdf);
			camel		= DelightItem(0x7F490734A412cDCc433D1B2aC688B76012380237);
			catapult	= DelightItem(0x9621F49513AfD44dDEF8c8c1FA494d594Ec626B5);
			crossbow	= DelightItem(0x530D749B7A44647469a3D0a2891C69295363D835);
			elephant	= DelightItem(0xC496d755d8307b1dC1222CDe02cC8780321eF6dF);
			hood		= DelightItem(0x58786a301Dc72FA1ca42D27157fA2104e44D04CC);
			shield		= DelightItem(0xB4F2494D6fED8DA0d0cac5722d0fA9693dd1202A);
			spear		= DelightItem(0xdc1DaC926C0C66A6EE4f22e201e60CB4C1A05755);
			
			// Knight item
			// 기사 아이템
			knightItem	= DelightKnightItemInterface(0xcaF1daACDC81F78b58BE9e48dC2585F2952dd8B9);
		}
		
		else if (network == Network.Ropsten) {
			
			// Items
			// 아이템
			axe			= DelightItem(0x2e9F717B4D29826e1e22e1849b7968Fe269C622d);
			ballista	= DelightItem(0x1FDc1459D4C296D1E6e4aA231a733E87069F23c9);
			camel		= DelightItem(0xdaAC439145D7114519Bd9f0BaB439eDaa64DF7d1);
			catapult	= DelightItem(0x19D8C0F2323Dd3cbFb0f6469ACb0C239a45B5cc2);
			crossbow	= DelightItem(0x61906522D49A12D43e76FB754019146518EE7324);
			elephant	= DelightItem(0x294C3738b3D53b9337FE68C2bd99DCAC235D410A);
			hood		= DelightItem(0x0d82A814A7191C785466835CE471CcD0e66C87ab);
			shield		= DelightItem(0x8EE990C7529AcB510bf1BA3373947226F3DFF5A9);
			spear		= DelightItem(0x3593FFa3906947F11251ee969D6571B1d9FC4914);
			
			// Knight item
			// 기사 아이템
			knightItem	= DelightKnightItemInterface(0xeF7cb3ac85E3b15CF3004a3Ea89e26DFAFb9D371);
		}
		
		else if (network == Network.Rinkeby) {
			
			// Items
			// 아이템
			axe			= DelightItem(0x440F68Aea046A0d5D338FA5B04257304E748cD4C);
			ballista	= DelightItem(0xF6FC0546e63F56b915b1fBb75B7D14E4551b0435);
			camel		= DelightItem(0xA278D6BFf4750731C516Ac14e66BF058c021c37A);
			catapult	= DelightItem(0x11C7656B4840347F89e76F70255c8A5250137f13);
			crossbow	= DelightItem(0x9E2d1a9A211953FD6Adde6a094D74a05F71BB421);
			elephant	= DelightItem(0x64e3F7dcFeEbD2CbA4F6A3cb454825cCDf403870);
			hood		= DelightItem(0x8B70794fB76b9c84006E4Eb501e143CE66BB7Cc0);
			shield		= DelightItem(0x4cf56d95aBA5fFA65637a0c20968D8b0d5D0Ceb8);
			spear		= DelightItem(0xD5639DD87C85C9cf48D64ecdfaA87430C1084215);
			
			// Knight item
			// 기사 아이템
			knightItem	= DelightKnightItemInterface(0x7bAD16534354FDFd0B020f54237eE4F61fB03726);
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
