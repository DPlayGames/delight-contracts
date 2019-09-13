pragma solidity ^0.5.9;

import "./DelightBase.sol";
import "./DelightItem.sol";
import "./Util/SafeMath.sol";

contract DelightItemManager is DelightBase {
	using SafeMath for uint;
	
	// 아이템을 생성합니다.
	function createItem(uint kind, uint count) internal returns (uint) {
		
		Material memory material = itemMaterials[kind];
		
		// 아이템을 생산하는데 필요한 자원이 충분한지 확인합니다.
		require(
			wood.balanceOf(msg.sender) >= material.wood.mul(count) &&
			stone.balanceOf(msg.sender) >= material.stone.mul(count) &&
			iron.balanceOf(msg.sender) >= material.iron.mul(count) &&
			ducat.balanceOf(msg.sender) >= material.ducat.mul(count)
		);
		
		DelightItem itemContract = getItemContract(kind);
		
		itemContract.assemble(msg.sender, count);
		
		emit CreateItem(msg.sender, kind, count);
	}
}