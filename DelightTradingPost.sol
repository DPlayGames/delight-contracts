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
		
		if (network == Network.Mainnet) {
			
			wood	= address(0x0);
			stone	= address(0x0);
			iron	= address(0x0);
			ducat	= address(0x0);
			
			axe			= address(0x0);
			ballista	= address(0x0);
			camel		= address(0x0);
			catapult	= address(0x0);
			crossbow	= address(0x0);
			elephant	= address(0x0);
			hood		= address(0x0);
			shield		= address(0x0);
			spear		= address(0x0);
			
			delightKnightItem = address(0x0);
			
			dplayTradingPost = DPlayTradingPostInterface(0x6242C1f2a80420576e14F239C9500Fc39438E880);
		}
		
		else if (network == Network.Kovan) {
			
			wood	= address(0x679b5E61cb379b624C57865184F0fc1055fF2451);
			stone	= address(0x03bd4ECD435Ba5d5A8c89d67E7A4958563b0De37);
			iron	= address(0x3A0Fc8db440F354BdCE7F5f769b672ff8d6e83A9);
			ducat	= address(0x9941c2639228d52fdF8Cea652F674b748f9e09b3);
			
			axe			= address(0x7D783328f639BFaa205D1385f254181A4e72F8Fe);
			ballista	= address(0x9BDadCAf2ff7143b34C455093e0722b401490fdf);
			camel		= address(0x7F490734A412cDCc433D1B2aC688B76012380237);
			catapult	= address(0x9621F49513AfD44dDEF8c8c1FA494d594Ec626B5);
			crossbow	= address(0x530D749B7A44647469a3D0a2891C69295363D835);
			elephant	= address(0xC496d755d8307b1dC1222CDe02cC8780321eF6dF);
			hood		= address(0x58786a301Dc72FA1ca42D27157fA2104e44D04CC);
			shield		= address(0xB4F2494D6fED8DA0d0cac5722d0fA9693dd1202A);
			spear		= address(0xdc1DaC926C0C66A6EE4f22e201e60CB4C1A05755);
			
			delightKnightItem = address(0xcaF1daACDC81F78b58BE9e48dC2585F2952dd8B9);
			
			dplayTradingPost = DPlayTradingPostInterface(0x80BB9F94cC7d437F322Ebb76BA694F74F0F2A8AC);
		}
		
		else if (network == Network.Ropsten) {
			
			wood	= address(0xb8383F77e3d5f2D4f34C830cC0a61e7502a5a7a3);
			stone	= address(0x82a0358E735B890E6d943bBe197906BFc5645145);
			iron	= address(0x72446703C3B06a448862Da7b260848Dc1A53B962);
			ducat	= address(0x58D5375b489a349f8181f016A536F7Ca155078D7);
			
			axe			= address(0x2e9F717B4D29826e1e22e1849b7968Fe269C622d);
			ballista	= address(0x1FDc1459D4C296D1E6e4aA231a733E87069F23c9);
			camel		= address(0xdaAC439145D7114519Bd9f0BaB439eDaa64DF7d1);
			catapult	= address(0x19D8C0F2323Dd3cbFb0f6469ACb0C239a45B5cc2);
			crossbow	= address(0x61906522D49A12D43e76FB754019146518EE7324);
			elephant	= address(0x294C3738b3D53b9337FE68C2bd99DCAC235D410A);
			hood		= address(0x0d82A814A7191C785466835CE471CcD0e66C87ab);
			shield		= address(0x8EE990C7529AcB510bf1BA3373947226F3DFF5A9);
			spear		= address(0x3593FFa3906947F11251ee969D6571B1d9FC4914);
			
			delightKnightItem = address(0xeF7cb3ac85E3b15CF3004a3Ea89e26DFAFb9D371);
			
			dplayTradingPost = DPlayTradingPostInterface(0x04db52D39f971074af8a6c248b909a36f133e862);
		}
		
		else if (network == Network.Rinkeby) {
			
			wood	= address(0x343CDA13Ad0Fc57dE12e66eA10BbCcce62F3668B);
			stone	= address(0x420e3F4721694b910F22325a3d8275Cd695c4F0c);
			iron	= address(0xf1F5cC7B93cf60A1218029c128128d78bdA043E8);
			ducat	= address(0x3570FEF1F5047BFBF222a2Ac9372c7F5479C875E);
			
			axe			= address(0x440F68Aea046A0d5D338FA5B04257304E748cD4C);
			ballista	= address(0xF6FC0546e63F56b915b1fBb75B7D14E4551b0435);
			camel		= address(0xA278D6BFf4750731C516Ac14e66BF058c021c37A);
			catapult	= address(0x11C7656B4840347F89e76F70255c8A5250137f13);
			crossbow	= address(0x9E2d1a9A211953FD6Adde6a094D74a05F71BB421);
			elephant	= address(0x64e3F7dcFeEbD2CbA4F6A3cb454825cCDf403870);
			hood		= address(0x8B70794fB76b9c84006E4Eb501e143CE66BB7Cc0);
			shield		= address(0x4cf56d95aBA5fFA65637a0c20968D8b0d5D0Ceb8);
			spear		= address(0xD5639DD87C85C9cf48D64ecdfaA87430C1084215);
			
			delightKnightItem = address(0x7bAD16534354FDFd0B020f54237eE4F61fB03726);
			
			dplayTradingPost = DPlayTradingPostInterface(0xff0ba06ec3b482dEdD8B4C3c1C348615b81EDBa8);
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