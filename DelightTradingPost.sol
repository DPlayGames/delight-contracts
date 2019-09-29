pragma solidity ^0.5.9;

import "./DelightTradingPostInterface.sol";
import "./DPlayTradingPostInterface.sol";
import "./Util/NetworkChecker.sol";
import "./Util/SafeMath.sol";

contract DelightTradingPost is DelightTradingPostInterface, NetworkChecker {
	using SafeMath for uint;
	
	// 자원들의 주소
	address internal wood;
	address internal stone;
	address internal iron;
	address internal ducat;
	
	// 일반 아이템들의 주소
	address public axe;
	address public spear;
	address public shield;
	address public hood;
	address public crossbow;
	address public ballista;
	address public catapult;
	address public camel;
	address public elephant;
	
	// 기사 아이템 주소
	address public delightKnightItem;
	
	DPlayTradingPostInterface private dplayTradingPost;
	
	constructor() NetworkChecker() public {
		
		// Loads the DPlay Coin smart contract.
		// DPlay Coin 스마트 계약을 불러옵니다.
		if (network == Network.Mainnet) {
			//TODO
		}
		
		else if (network == Network.Kovan) {
			
			wood	= address(0xcB442FdeA4351A1a92c3FBcfE84e5Aeced1cAF7C);
			stone	= address(0x69AD905736aEdA809C7d3ac2BC519D6675258558);
			iron	= address(0xC4e01C58e58196E90E93f6a25E0cc56D12163681);
			ducat	= address(0x045888211D9C1Bc1c564592b8c457e2d54776b6D);
			
			axe			= address(0x709B32a817Cd27e9B21513818F5650Db681F9C6B);
			ballista	= address(0x769E4d36e7a6A9579002875C41072A50CB64C646);
			camel		= address(0xa1ebFB45f76728be1D1C7CE9ed5b7eE3Af955d1b);
			catapult	= address(0x19Ee2B87bDF14665A2b6f8d3CA2f3818dA077206);
			crossbow	= address(0x8834F024eC4b298D75E2F634A6A714B6A92B3AE3);
			elephant	= address(0xf3Bff581f943d408606F4ef05175b8b65589D34F);
			hood		= address(0x890007687Ba2dce4AD91a0C7DAC05D08628d32A7);
			shield		= address(0xb60Df1dF1E23290B013e0B7fbE8E5318FC0D6646);
			spear		= address(0xd948AF9FfA7572a72caF9AA82a6eCE0f8EC17357);
			
			delightKnightItem = address(0xF53aa613fecb8450F3d39533A4daE4AA98159889);
			
			dplayTradingPost = DPlayTradingPostInterface(0x980f391C9C36BD6d95F5676dDfa7a3B414404570);
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
	
	// 자원 판매 ID들을 가져옵니다.
	function getResourceSaleIds() view external returns (uint[] memory) {
		
		uint saleCount = 0;
		
		for (uint i = 0; i < dplayTradingPost.getResourceSaleCount(); i += 1) {
			
			(
				,
				address resourceAddress,
				,
				,
				,
				
			) = dplayTradingPost.getResourceSaleInfo(i);
			
			if (
				resourceAddress == wood ||
				resourceAddress == stone ||
				resourceAddress == iron ||
				resourceAddress == ducat
			) {
				saleCount += 1;
			}
		}
		
		uint[] memory saleIds = new uint[](saleCount);
		uint j = 0;
		
		for (uint i = 0; i < dplayTradingPost.getResourceSaleCount(); i += 1) {
			
			(
				,
				address resourceAddress,
				,
				,
				,
				
			) = dplayTradingPost.getResourceSaleInfo(i);
			
			if (
				resourceAddress == wood ||
				resourceAddress == stone ||
				resourceAddress == iron ||
				resourceAddress == ducat
			) {
				saleIds[j] = i;
				j += 1;
			}
		}
		
		return saleIds;
	}
	
	// 아이템 판매 ID들을 가져옵니다.
	function getItemSaleIds() view external returns (uint[] memory) {
		
		uint saleCount = 0;
		
		for (uint i = 0; i < dplayTradingPost.getItemSaleCount(); i += 1) {
			
			(
				,
				address[] memory itemAddresses,
				,
				,
				,
				
			) = dplayTradingPost.getItemSaleInfo(i);
			
			for (uint j = 0; j < itemAddresses.length; j += 1) {
				
				if (
					itemAddresses[j] == axe ||
					itemAddresses[j] == spear ||
					itemAddresses[j] == shield ||
					itemAddresses[j] == hood ||
					itemAddresses[j] == crossbow ||
					itemAddresses[j] == ballista ||
					itemAddresses[j] == catapult ||
					itemAddresses[j] == camel ||
					itemAddresses[j] == elephant
				) {
					saleCount += 1;
					break;
				}
			}
		}
		
		uint[] memory saleIds = new uint[](saleCount);
		uint k = 0;
		
		for (uint i = 0; i < dplayTradingPost.getItemSaleCount(); i += 1) {
			
			(
				,
				address[] memory itemAddresses,
				,
				,
				,
				
			) = dplayTradingPost.getItemSaleInfo(i);
			
			for (uint j = 0; j < itemAddresses.length; j += 1) {
				
				if (
					itemAddresses[j] == axe ||
					itemAddresses[j] == spear ||
					itemAddresses[j] == shield ||
					itemAddresses[j] == hood ||
					itemAddresses[j] == crossbow ||
					itemAddresses[j] == ballista ||
					itemAddresses[j] == catapult ||
					itemAddresses[j] == camel ||
					itemAddresses[j] == elephant
				) {
					saleIds[k] = i;
					k += 1;
					break;
				}
			}
		}
		
		return saleIds;
	}
	
	// 기사 아이템 판매 ID들을 가져옵니다.
	function getKnightItemSaleIds() view external returns (uint[] memory) {
		
		uint saleCount = 0;
		
		for (uint i = 0; i < dplayTradingPost.getUniqueItemSaleCount(); i += 1) {
			
			(
				,
				address[] memory itemAddresses,
				,
				,
				,
				
			) = dplayTradingPost.getUniqueItemSaleInfo(i);
			
			for (uint j = 0; j < itemAddresses.length; j += 1) {
				
				if (itemAddresses[j] == delightKnightItem) {
					saleCount += 1;
					break;
				}
			}
		}
		
		uint[] memory saleIds = new uint[](saleCount);
		uint k = 0;
		
		for (uint i = 0; i < dplayTradingPost.getUniqueItemSaleCount(); i += 1) {
			
			(
				,
				address[] memory itemAddresses,
				,
				,
				,
				
			) = dplayTradingPost.getUniqueItemSaleInfo(i);
			
			for (uint j = 0; j < itemAddresses.length; j += 1) {
				
				if (itemAddresses[j] == delightKnightItem) {
					saleIds[k] = i;
					k += 1;
					break;
				}
			}
		}
		
		return saleIds;
	}
}