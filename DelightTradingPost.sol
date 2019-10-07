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
			
			wood	= address(0x960cDd85069a5daE6EEB6a35f3626Fc3c720FC5f);
			stone	= address(0x1587e0142509330f7Fd8Db994Ad6E2D5D3830877);
			iron	= address(0x812a757f62C801FEA1d52EFCB997Af588f1caD4D);
			ducat	= address(0x0aEB1856F095eB3f1d0c428E8b166677D0833243);
			
			axe			= address(0xb71321Ca625214be6531dBe1E54754d4D008eaE8);
			ballista	= address(0xc840F46e3b43d81B3737F24e7320Fa7af2bA4047);
			camel		= address(0x8A2fece743833b67dFbA5cd53b750643Aa95FeD4);
			catapult	= address(0xFFD938a469354ebeed76fBcdA2d47569289Ecd61);
			crossbow	= address(0x5f0673c83d68C6a49febD909ffE466267340Cef9);
			elephant	= address(0x61C5a4de58049706d819ab2643A1d5C798726882);
			hood		= address(0x0b28f2851707385759571c28Adc4A3d464dF9058);
			shield		= address(0xBB662C21E42Be9696F677F6d0FBEC8cC68585ed4);
			spear		= address(0x62632d9EDBdB32C7f71cCdb6a0B615D7EeD6Ee15);
			
			delightKnightItem = address(0x4D30e2A1c9dF335f2eFd9E5EC3390Bc56Df42CF5);
			
			dplayTradingPost = DPlayTradingPostInterface(0x04f5e615dbda0DA4625d413C0FC3cA5aEc847EF2);
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