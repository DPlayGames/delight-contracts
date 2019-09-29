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
			info	= DelightInfoInterface(0x2f0d5316251933341a05926a4b3134f92c17D239);
			
			// Resources
			// 자원들
			wood	= DelightResource(0x8B2C13385D3c53c831DD546bd67F3cfA316E4c46);
			stone	= DelightResource(0x61d054B5969300A2E06a493c4232885d8D0aCf1d);
			iron	= DelightResource(0x3b6a03f5487f275A89830040646E7BC45B8670EA);
			ducat	= DelightResource(0x1ba8D3b148f62c2Ba3E4262bD760644d034Dea64);
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
