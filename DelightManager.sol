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
			info	= DelightInfoInterface(0xAbA87969Ccbcbd841c559EA1d39774BFbc3801e8);
			
			// Resources
			// 자원들
			wood	= DelightResource(0x0b45e9B0E8390a4396c3145BDAd62c817217bdB9);
			stone	= DelightResource(0x91892b5Abb73270Bea9796019fE79070812ca3d7);
			iron	= DelightResource(0x8474A0f99bfdd74Dbd8E2cD18E83107f2e3f2720);
			ducat	= DelightResource(0x50E4Ce7BdfA465F4D2AC09084323fcdCfe8E011B);
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
