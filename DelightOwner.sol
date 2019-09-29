pragma solidity ^0.5.9;

import "./DelightOwnerInterface.sol";
import "./DelightInterface.sol";
import "./DelightBuildingManagerInterface.sol";
import "./DelightArmyManagerInterface.sol";
import "./Util/NetworkChecker.sol";
import "./Util/SafeMath.sol";

contract DelightOwner is DelightOwnerInterface, NetworkChecker {
	using SafeMath for uint;
	
	DelightInterface private delight;
	DelightBuildingManagerInterface private buildingManager;
	DelightArmyManagerInterface private armyManager;
	
	constructor() NetworkChecker() public {
		
		if (network == Network.Mainnet) {
			//TODO
		}
		
		else if (network == Network.Kovan) {
			delight			= DelightInterface(0x718f7E95eC0D5F59287AfC2919b81BAbcFa091F8);
			buildingManager	= DelightBuildingManagerInterface(0x8aAD0Da8c776131377f2c4bC82E5Ad4211D897d4);
			armyManager		= DelightArmyManagerInterface(0xB2dc34a4Fa8C8CA7005F040F7B26B8C2bd8Cf1cD);
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
}
