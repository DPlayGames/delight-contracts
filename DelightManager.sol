pragma solidity ^0.5.9;

import "./DelightBase.sol";
import "./DelightResource.sol";
import "./DelightInfoInterface.sol";
import "./Util/NetworkChecker.sol";
import "./Util/SafeMath.sol";

contract DelightManager is DelightBase, NetworkChecker {
	using SafeMath for uint;
	
	// Delight basic information
	// Delight 기본 정보
	DelightInfoInterface internal info;
	
	// Resources
	// 자원들
	DelightResource internal wood;
	DelightResource internal stone;
	DelightResource internal iron;
	DelightResource internal ducat;
	
	constructor() NetworkChecker() public {
		
		if (network == Network.Mainnet) {
			
			// Delight basic information
			// Delight 기본 정보
			info	= DelightInfoInterface(0x7e04BedFd6721589f5557385063cf07Ce40262e3);
			
			// Resources
			// 자원들
			wood	= DelightResource(0x8c804fB79fBD54c333aDBee39F55624C40eC4bE6);
			stone	= DelightResource(0x65AA2BaaE7a71C3012E114C90834339a26719508);
			iron	= DelightResource(0xE9Df44e3b7f3a2DC179237ddD5E104Ff69Db3C9D);
			ducat	= DelightResource(0x664F414d84Cf88a377F4B116273A327e3b6D9ffB);
		}
		
		else if (network == Network.Kovan) {
			
			// Delight basic information
			// Delight 기본 정보
			info	= DelightInfoInterface(0x5b17bB8500702aa394989B8db53D348897900EF6);
			
			// Resources
			// 자원들
			wood	= DelightResource(0x679b5E61cb379b624C57865184F0fc1055fF2451);
			stone	= DelightResource(0x03bd4ECD435Ba5d5A8c89d67E7A4958563b0De37);
			iron	= DelightResource(0x3A0Fc8db440F354BdCE7F5f769b672ff8d6e83A9);
			ducat	= DelightResource(0x9941c2639228d52fdF8Cea652F674b748f9e09b3);
		}
		
		else if (network == Network.Ropsten) {
			
			// Delight basic information
			// Delight 기본 정보
			info	= DelightInfoInterface(0x25f0A1da6dD8D161378cf738D422a66Ecd286881);
			
			// Resources
			// 자원들
			wood	= DelightResource(0xb8383F77e3d5f2D4f34C830cC0a61e7502a5a7a3);
			stone	= DelightResource(0x82a0358E735B890E6d943bBe197906BFc5645145);
			iron	= DelightResource(0x72446703C3B06a448862Da7b260848Dc1A53B962);
			ducat	= DelightResource(0x58D5375b489a349f8181f016A536F7Ca155078D7);
		}
		
		else if (network == Network.Rinkeby) {
			
			// Delight basic information
			// Delight 기본 정보
			info	= DelightInfoInterface(0x8711670B68FAC7a47b1232E87Fa62cdAeb6040E4);
			
			// Resources
			// 자원들
			wood	= DelightResource(0x343CDA13Ad0Fc57dE12e66eA10BbCcce62F3668B);
			stone	= DelightResource(0x420e3F4721694b910F22325a3d8275Cd695c4F0c);
			iron	= DelightResource(0xf1F5cC7B93cf60A1218029c128128d78bdA043E8);
			ducat	= DelightResource(0x3570FEF1F5047BFBF222a2Ac9372c7F5479C875E);
		}
		
		else {
			revert();
		}
	}
	
	// The address of the Delight.
	// Delight 주소
	address internal delight;
	
	function setDelightOnce(address addr) external {
		
		// The address has to be empty.
		// 비어있는 주소인 경우에만
		require(delight == address(0));
		
		delight = addr;
	}
}
