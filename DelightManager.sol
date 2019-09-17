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
			info	= DelightInfoInterface(0x23A006145E4Ea87850423ac3a7343dC37D9354F2);
			
			// 자원들
			wood	= DelightResource(0x699F2c6FF4c208C41DDe9832184972d45fb00F60);
			stone	= DelightResource(0x16c56C7c7A0bC53Fb373EFCe5C33acbfBF98Cac3);
			iron	= DelightResource(0x6850463Fd3cED631c00c807c179D66Eb3e27a733);
			ducat	= DelightResource(0xF3fD4f001f6281c0F682746A5bB863f8122305eE);
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