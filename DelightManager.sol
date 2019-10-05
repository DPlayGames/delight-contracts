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
			info	= DelightInfoInterface(0x27e0eA111CE3cFf6d65D6Ee91bA64ce6cDe2f0B0);
			
			// Resources
			// 자원들
			wood	= DelightResource(0xB0D7AFeD1878a851Bc6353d1c69F6cD304C0eE90);
			stone	= DelightResource(0xfe41139fD22C9751752EfCBA5A182d347C9F5841);
			iron	= DelightResource(0x724a85bf1d5bd9eba8cF7438174a22ef6907299a);
			ducat	= DelightResource(0xE10492efb1314ec6f4573Cf2d2E83eD10988619a);
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
