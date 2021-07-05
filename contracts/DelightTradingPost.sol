pragma solidity ^0.5.9;

import "./DelightTradingPostInterface.sol";
import "./DPlayTradingPostInterface.sol";
import "./Util/SafeMath.sol";

contract DelightTradingPost is DelightTradingPostInterface {
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
	
	constructor(
		address _wood,
		address _stone,
		address _iron,
		address _ducat,

		address _axe,
		address _ballista,
		address _camel,
		address _catapult,
		address _crossbow,
		address _elephant,
		address _hood,
		address _shield,
		address _spear,

		address _delightKnightItem,
		DPlayTradingPostInterface _dplayTradingPost
	) public {
		
		wood	= _wood;
		stone	= _stone;
		iron	= _iron;
		ducat	= _ducat;
		
		axe			= _axe;
		ballista	= _ballista;
		camel		= _camel;
		catapult	= _catapult;
		crossbow	= _crossbow;
		elephant	= _elephant;
		hood		= _hood;
		shield		= _shield;
		spear		= _spear;
		
		delightKnightItem = _delightKnightItem;
		dplayTradingPost = _dplayTradingPost;
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