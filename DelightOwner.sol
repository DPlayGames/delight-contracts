pragma solidity ^0.5.9;

import "./DelightOwnerInterface.sol";
import "./DelightBuildingManager.sol";
import "./DelightArmyManager.sol";
import "./Util/NetworkChecker.sol";
import "./Util/SafeMath.sol";

contract DelightOwner is DelightOwnerInterface, NetworkChecker {
	using SafeMath for uint;
	
	DelightBuildingManager private delightBuildingManager;
	DelightArmyManager private delightArmyManager;
	
	constructor() NetworkChecker() public {
		
		if (network == Network.Mainnet) {
			//TODO
		}
		
		else if (network == Network.Kovan) {
			//TODO
			delightBuildingManager	= DelightBuildingManager(0x0f3B145F0C104C42d522f9c188faE90239c2B2Bd);
			delightArmyManager		= DelightArmyManager(0xB1cA4eE80181E196F1dA39D44299D180B63b8018);
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
	
	// 소유주의 건물 ID들을 가져옵니다.
	function getBuildingIds(address owner) view external returns (uint[] memory) {
		
		uint buildingCount = 0;
		
		for (uint i = 0; i < delightBuildingManager.getBuildingCount(); i += 1) {
			
			(
				,
				,
				,
				,
				address buildingOwner,
				
			) = delightBuildingManager.getBuildingInfo(i);
			
			if (buildingOwner == owner) {
				buildingCount += 1;
			}
		}
		
		uint[] memory buildingIds = new uint[](buildingCount);
		uint j = 0;
		
		for (uint i = 0; i < delightBuildingManager.getBuildingCount(); i += 1) {
			
			(
				,
				,
				,
				,
				address buildingOwner,
				
			) = delightBuildingManager.getBuildingInfo(i);
			
			if (buildingOwner == owner) {
				buildingIds[j] = i;
				j += 1;
			}
		}
		
		return buildingIds;
	}
	
	// 소유주의 부대 ID들을 가져옵니다.
	function getArmyIds(address owner) view external returns (uint[] memory) {
		
		uint armyCount = 0;
		
		for (uint i = 0; i < delightArmyManager.getArmyCount(); i += 1) {
			
			(
				,
				,
				,
				,
				,
				address armyOwner,
				
			) = delightArmyManager.getArmyInfo(i);
			
			if (armyOwner == owner) {
				armyCount += 1;
			}
		}
		
		uint[] memory armyIds = new uint[](armyCount);
		uint j = 0;
		
		for (uint i = 0; i < delightArmyManager.getArmyCount(); i += 1) {
			
			(
				,
				,
				,
				,
				,
				address armyOwner,
				
			) = delightArmyManager.getArmyInfo(i);
			
			if (armyOwner == owner) {
				armyIds[j] = i;
				j += 1;
			}
		}
		
		return armyIds;
	}
}