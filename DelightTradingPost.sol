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
			
			wood	= address(0x2dace0bb1073555f7F95D7614A3aC2237FcD7f56);
			stone	= address(0xa1CA3406741144bD439De12323C797244509C51F);
			iron	= address(0x32547481C71A1B8083873B70e0752cfB286DADa5);
			ducat	= address(0xf8222FE259A7d4F76DB1b47B2807d799ce3F4AF8);
			
			axe			= address(0x4f335332cf93120Fa319E13cbDA35534Edf684ED);
			ballista	= address(0xA46220B38316bBaBfa6bC0d2fdFBd8985bfdAdfe);
			camel		= address(0x0F3AeB04F59FDD596fE5ef652eaB39f66eB64eb6);
			catapult	= address(0xcf0D83AE9cb5401E3F6F99066694ffbe971cd816);
			crossbow	= address(0x0011909E6b8bDC2591f48820706175Eac67b9B80);
			elephant	= address(0x9f912aeD1F6e7F202035f3926CC6AF18a89d8213);
			hood		= address(0x10E00d0a3b619D9a878088f0080d8dA2E49d8341);
			shield		= address(0xBF80B0b34C957f371E4BC4C32D00824386b5791d);
			spear		= address(0x2380aCC3e2183AcE58D6190d4B47792b8Db56a8E);
			
			delightKnightItem = address(0x27E124cf79348F06345C9D97F557743Cf485c9EA);
			
			dplayTradingPost = DPlayTradingPostInterface(0xEcDc20F027fF277Dc10DE039d5409D433Bec5eE3);
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