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
			info	= DelightInfoInterface(0x492d67b58608aB6874B033fE05309C307BA7026f);
			
			// Resources
			// 자원들
			wood	= DelightResource(0xDDAF42F14a5bDd0aE6dFC9ADfa4086d7dcb520ee);
			stone	= DelightResource(0xfF75796288ef47AA83c67D529D7D7755829085ee);
			iron	= DelightResource(0x4f1376d17E5e8cFF811Ae6267F15c20161FCD20C);
			ducat	= DelightResource(0xeeFC6B4aE346EdB77E0b36d8443fD3A4bc1Dc9F2);
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
