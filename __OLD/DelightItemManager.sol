pragma solidity ^0.5.9;

import "./DelightBase.sol";
import "./DelightItem.sol";
import "./Util/SafeMath.sol";

contract DelightItemManager is DelightBase {
	using SafeMath for uint;
	
	// 아이템을 생성합니다.
	function createItem(uint kind, uint count) internal returns (uint) {
		
		Material memory itemMaterial = itemMaterials[kind];
		Material memory material = Material({
			wood : itemMaterial.wood.mul(count),
			stone : itemMaterial.stone.mul(count),
			iron : itemMaterial.iron.mul(count),
			ducat : itemMaterial.ducat.mul(count)
		});
		
		// 아이템을 생산하는데 필요한 자원이 충분한지 확인합니다.
		require(
			wood.balanceOf(msg.sender) >= material.wood &&
			stone.balanceOf(msg.sender) >= material.stone &&
			iron.balanceOf(msg.sender) >= material.iron &&
			ducat.balanceOf(msg.sender) >= material.ducat
		);
		
		DelightItem itemContract = getItemContract(kind);
		
		itemContract.assemble(msg.sender, count);
		
		// 기록을 저장합니다.
		
		
		// 이벤트 발생
		emit CreateItem(msg.sender, kind, count, material.wood, material.stone, material.iron, material.ducat);
	}
}