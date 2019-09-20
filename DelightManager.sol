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
			info	= DelightInfoInterface(0x3fF8d80D0f05812471099b25267128140C111B1f);
			
			// Resources
			// 자원들
			wood	= DelightResource(0x0a601E5B18D6729AA0259F4C157404721ceBB60f);
			stone	= DelightResource(0xC731E8a07322b9595A913f670cDEBebBCf0E9cB2);
			iron	= DelightResource(0x681C8958b10c807Ae496d1cA9Aa7146cCB7EACF8);
			ducat	= DelightResource(0x04678e65A52A663dccB3001813A07ed89B003FcC);
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
