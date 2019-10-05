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
			info	= DelightInfoInterface(0x0bcd60d9961d7DBf7d87568c14520A35D1978860);
			
			// Resources
			// 자원들
			wood	= DelightResource(0x94f8a8f0b1da163BFA44B35ae252b0C317884722);
			stone	= DelightResource(0xfc58a0C3c7CB19e6ceaF2AEa01a215350A108C7F);
			iron	= DelightResource(0x5004BB1032f56ee487AB214252D6A7dC4bbAE5D6);
			ducat	= DelightResource(0x18D022674C540b63C8Bb650680480E3645561Ee3);
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
