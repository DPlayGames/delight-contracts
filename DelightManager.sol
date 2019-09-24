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
			info	= DelightInfoInterface(0x13e0ec29d53c2984e2157AA6594b45D68e66b18A);
			
			// Resources
			// 자원들
			wood	= DelightResource(0x50ab7f8B81932DE37a694e7ff3158BdC626Ca189);
			stone	= DelightResource(0xc8C20f552558B56EaC721374ee7Bb7b741A22f17);
			iron	= DelightResource(0x80067ce57D285377F4F61Aa8fAFd0364dCd5fd2b);
			ducat	= DelightResource(0x452c7ECd6bf7B3a8B5F84c26Dd8B202E87f0Ec0e);
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
