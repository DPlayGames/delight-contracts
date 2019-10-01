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
			//TODO
		}
		
		else if (network == Network.Kovan) {
			
			// Delight basic information
			// Delight 기본 정보
			info	= DelightInfoInterface(0x9Faeb4E41Fb0DE0dA7E2274c8Fb35EDaa39e365E);
			
			// Resources
			// 자원들
			wood	= DelightResource(0x66a412038bb8e6F4b9f5597Bd579465E7Fc1Deb5);
			stone	= DelightResource(0xD3F9FF0EB49EBbBc6E4FdCCFb6512bb221786593);
			iron	= DelightResource(0xE2d3BEF06C7dD2b0b1d9a4A885d0864f8c3D8199);
			ducat	= DelightResource(0xd8A1388D10d37374968D4E489E3dB451E00E92db);
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
