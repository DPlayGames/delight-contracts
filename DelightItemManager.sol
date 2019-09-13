pragma solidity ^0.5.9;

import "./DelightBase.sol";
import "./DelightItem.sol";
import "./Util/SafeMath.sol";

contract DelightItemManager is DelightBase {
	using SafeMath for uint;
	
	// 아이템을 생성합니다.
	function createItem(uint kind, uint count) external returns (uint) {
		
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
		history.push(Record({
			kind : RECORD_CREATE_ITEM,
			
			owner : msg.sender,
			enemy : address(0x0),
			
			col : 0,
			row : 0,
			toCol : 0,
			toRow : 0,
			
			buildingId : 0,
			buildingKind : 0,
			buildingLevel : 0,
			
			armyId : 0,
			unitKind : 0,
			unitCount : 0,
			
			itemId : 0,
			itemKind : kind,
			itemCount : count,
			
			wood : material.wood,
			stone : material.stone,
			iron : material.iron,
			ducat : material.ducat,
			
			enemyWood : 0,
			enemyStone : 0,
			enemyIron : 0,
			enemyDucat : 0,
			
			time : now
		}));
		
		// 이벤트 발생
		emit CreateItem(msg.sender, kind, count, material.wood, material.stone, material.iron, material.ducat);
	}
}