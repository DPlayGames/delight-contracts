pragma solidity ^0.5.9;

import "./DelightOwnerInterface.sol";
import "./DelightInterface.sol";
import "./DelightBuildingManagerInterface.sol";
import "./DelightArmyManagerInterface.sol";
import "./DelightKnightItemInterface.sol";
import "./Util/NetworkChecker.sol";
import "./Util/SafeMath.sol";

contract DelightOwner is DelightOwnerInterface, NetworkChecker {
	using SafeMath for uint;
	
	DelightInterface private delight;
	DelightBuildingManagerInterface private buildingManager;
	DelightArmyManagerInterface private armyManager;
	
	// Knight item
	// 기사 아이템
	DelightKnightItemInterface private knightItem;
	
	constructor() NetworkChecker() public {
		
		if (network == Network.Mainnet) {
			//TODO
		}
		
		else if (network == Network.Kovan) {
			
			delight			= DelightInterface(0x8BAE93C8bEf6C3703ca9fA29f79cAB3d4C42B570);
			buildingManager	= DelightBuildingManagerInterface(0xcF6cbfF2d1FCc814156D0862bBe0597195A0Ea1D);
			armyManager		= DelightArmyManagerInterface(0xded95e400Ad93763820BA6762292e8f1bc014910);
			
			// knight item.
			// 기사 아이템
			knightItem		= DelightKnightItemInterface(0x6c46E94E27a86C845FB1c09B1dE8C2514Fe4ADf8);
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
	
	// Gets the record IDs of the owner.
	// 소유주의 기록 ID들을 가져옵니다.
	function getRecordIds(address owner) view external returns (uint[] memory) {
		
		uint recordCount = 0;
		
		for (uint i = 0; i < delight.getRecordCount(); i += 1) {
			
			(
				,
				address account,
				,
				,
				,
				,
				,
				,
				,
				
			) = delight.getRecord(i);
			
			if (account == owner) {
				recordCount += 1;
			}
		}
		
		uint[] memory recordIds = new uint[](recordCount);
		uint j = 0;
		
		for (uint i = 0; i < delight.getRecordCount(); i += 1) {
			
			(
				,
				address account,
				,
				,
				,
				,
				,
				,
				,
				
			) = delight.getRecord(i);
			
			if (account == owner) {
				recordIds[j] = i;
				j += 1;
			}
		}
		
		return recordIds;
	}
	
	// Gets the building IDs of the owner.
	// 소유주의 건물 ID들을 가져옵니다.
	function getBuildingIds(address owner) view external returns (uint[] memory) {
		
		uint buildingCount = 0;
		
		for (uint i = 0; i < buildingManager.getBuildingCount(); i += 1) {
			
			(
				,
				,
				,
				,
				address buildingOwner,
				
			) = buildingManager.getBuildingInfo(i);
			
			if (buildingOwner == owner) {
				buildingCount += 1;
			}
		}
		
		uint[] memory buildingIds = new uint[](buildingCount);
		uint j = 0;
		
		for (uint i = 0; i < buildingManager.getBuildingCount(); i += 1) {
			
			(
				,
				,
				,
				,
				address buildingOwner,
				
			) = buildingManager.getBuildingInfo(i);
			
			if (buildingOwner == owner) {
				buildingIds[j] = i;
				j += 1;
			}
		}
		
		return buildingIds;
	}
	
	// Gets the Army IDs of the owner.
	// 소유주의 부대 ID들을 가져옵니다.
	function getArmyIds(address owner) view external returns (uint[] memory) {
		
		uint armyCount = 0;
		
		for (uint i = 0; i < armyManager.getArmyCount(); i += 1) {
			
			(
				,
				,
				,
				,
				,
				address armyOwner,
				
			) = armyManager.getArmyInfo(i);
			
			if (armyOwner == owner) {
				armyCount += 1;
			}
		}
		
		uint[] memory armyIds = new uint[](armyCount);
		uint j = 0;
		
		for (uint i = 0; i < armyManager.getArmyCount(); i += 1) {
			
			(
				,
				,
				,
				,
				,
				address armyOwner,
				
			) = armyManager.getArmyInfo(i);
			
			if (armyOwner == owner) {
				armyIds[j] = i;
				j += 1;
			}
		}
		
		return armyIds;
	}
	
	// Gets the knight IDs of the owner.
	// 소유주의 기사 ID들을 가져옵니다.
	function getKnightItemIds(address owner) view external returns (uint[] memory) {
		
		uint itemCount = 0;
		
		for (uint i = 0; i < knightItem.getItemCount(); i += 1) {
			if (knightItem.ownerOf(i) == owner) {
				itemCount += 1;
			}
		}
		
		uint[] memory itemIds = new uint[](itemCount);
		uint j = 0;
		
		for (uint i = 0; i < knightItem.getItemCount(); i += 1) {
			if (knightItem.ownerOf(i) == owner) {
				itemIds[j] = i;
				j += 1;
			}
		}
		
		return itemIds;
	}
}
