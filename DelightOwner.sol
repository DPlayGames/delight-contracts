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
			
			delight			= DelightInterface(0x8d3F8fb6152De1F4C511280061B6844a9315b743);
			buildingManager	= DelightBuildingManagerInterface(0xF4915d197De2E263c9649abe735A2180048eABfa);
			armyManager		= DelightArmyManagerInterface(0x5D89d8B4f10c5c5AbfCE538A2E0E8eB343380027);
			
			// knight item.
			// 기사 아이템
			knightItem		= DelightKnightItemInterface(0x01C3Eac09cE9e59A2aEC034745A09593736af39b);
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
