pragma solidity ^0.5.9;

import "./DelightBase.sol";
import "./DelightInfo.sol";
import "./DelightResource.sol";
import "./Util/NetworkChecker.sol";
import "./Util/SafeMath.sol";

contract DelightManager is DelightBase, NetworkChecker {
	using SafeMath for uint;
	
	// Delight 주소
	address public delight;
	
	function setDelightOnce(address addr) external {
		
		// 비어있는 주소인 경우에만
		require(delight == address(0));
		
		delight = addr;
	}
	
	DelightInfo internal info;
	
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
			info	= DelightInfo(0x50f28E3a2c31458a919089C94C45b39eB792f06D);
			
			// 자원들
			wood	= DelightResource(0x12e086D2697FC4B2DE25237Fa8e89CEEae8e949b);
			stone	= DelightResource(0xdd77021e84Fff63bB7685ab18560434C4E5eE201);
			iron	= DelightResource(0x1191E043a9c0DE374fb2e7ed8f3f10e7a4004DcE);
			ducat	= DelightResource(0x585111f181632271Ffc29d2E633cECBe53A9886D);
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