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
			info	= DelightInfoInterface(0x5c0a567F5E1606B338735243ddd74041F30E3c8e);
			
			// Resources
			// 자원들
			wood	= DelightResource(0xD2cCb6c4d7B302d234c31a1977c9E3280c6D8CBc);
			stone	= DelightResource(0x02cF7263eb1FB7BeE61D8b8AA34a2fA24188c91c);
			iron	= DelightResource(0x5848513E9849a7998F7FC8f997497Fa3Ffb7030F);
			ducat	= DelightResource(0x404dA20aB54Be6Ab5c19aE40B5614e5a8E8748A1);
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
