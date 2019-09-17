pragma solidity ^0.5.9;

import "./DelightBase.sol";
import "./DelightResource.sol";
import "./DelightInfoInterface.sol";
import "./Util/NetworkChecker.sol";
import "./Util/SafeMath.sol";

contract DelightManager is DelightBase, NetworkChecker {
	using SafeMath for uint;
	
	// Delight 주소
	address internal delight;
	
	function setDelightOnce(address addr) external {
		
		// 비어있는 주소인 경우에만
		require(delight == address(0));
		
		delight = addr;
	}
	
	DelightInfoInterface internal info;
	
	DelightResource internal wood;
	DelightResource internal stone;
	DelightResource internal iron;
	DelightResource internal ducat;
	
	constructor() NetworkChecker() public {
		
		if (network == Network.Mainnet) {
			//TODO
		}
		
		else if (network == Network.Kovan) {
			//TODO
			
			// 정보
			info	= DelightInfoInterface(0x27dd4D781d69b0739Cd6bFb77A9cBc0419171167);
			
			// 자원들
			wood	= DelightResource(0xb201C0BE2E5aC35a3c951756abE9BCb6D51B4787);
			stone	= DelightResource(0x9709442cA271f9D1AEe8a5d6DdD33699B533DfdA);
			iron	= DelightResource(0x12FE1071Ea32ea211a90b1d8b9C182CF51bB26fc);
			ducat	= DelightResource(0xc9e8985208923883b4150Fa48c1F87607F08B789);
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
}