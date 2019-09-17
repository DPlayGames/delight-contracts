pragma solidity ^0.5.9;

import "./DelightManager.sol";
import "./DelightItem.sol";
import "./DelightKnightItem.sol";
import "./Util/SafeMath.sol";

contract DelightItemManager is DelightManager {
	using SafeMath for uint;
	
	// Delight 부대 관리자 주소
	address private delightArmyManager;
	
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
	
	DelightItem public axe;
	DelightItem public spear;
	DelightItem public shield;
	DelightItem public hood;
	DelightItem public crossbow;
	DelightItem public ballista;
	DelightItem public catapult;
	DelightItem public camel;
	DelightItem public elephant;
	
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
			
			// 아이템
			axe			= DelightItem(0x64cE264C86Ff720bd6B8AD3Bd0D1b1378e1Ec690);
			ballista	= DelightItem(0xB6cf871358307Fa3eCd5A4CaE225ba1d57ff088D);
			camel		= DelightItem(0xFd7E1c6734002AbA9b37a17C9B36fAf5Da0acaA4);
			catapult	= DelightItem(0xC256E5a8149D190Fe98407A96395cAe7Ec770Adb);
			crossbow	= DelightItem(0x4330230e3B8B24662f016fD4ea09DB51Bc152F14);
			elephant	= DelightItem(0x525454177Ee05B8E888f4539Fb95574E78309AC4);
			hood		= DelightItem(0xaDFC2868437fb8e555f391ffD785C9e85F6dAb60);
			shield		= DelightItem(0x2699485976217570076c2e60eefC853A92876D19);
			spear		= DelightItem(0xfD396Ce25c3424A95a56Cc6fafe82cCf13F4254A);
			
			// 기사 아이템
			knightItem	= DelightKnightItem(0x493620441D6A3f19cab31b1DDad965eD99E4e8E0);
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
	function disassembleItem(uint kind, uint count) onlyDelight external {
		
		DelightItem itemContract = getItemContract(kind);
		
		// 아이템을 분해합니다.
		itemContract.disassemble(count);
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