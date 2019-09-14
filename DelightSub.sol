pragma solidity ^0.5.9;

import "./DelightBase.sol";
import "./DelightHistoryInterface.sol";
import "./Util/SafeMath.sol";

contract DelightSub is DelightBase {
	using SafeMath for uint;
	
	// Delight 주소
	address public delight;
	
	function setDelightOnce(address addr) external {
		
		// 비어있는 주소인 경우에만
		require(delight == address(0));
		
		delight = addr;
	}
	
	// Sender가 Delight일때만 실행
	modifier onlyDelight() {
		require(msg.sender == delight);
		_;
	}
	
	DelightHistoryInterface internal delightHistory;
	
	constructor() DelightBase() public {
		
		// DPlay History 스마트 계약을 불러옵니다.
		if (network == Network.Mainnet) {
			//TODO
		} else if (network == Network.Kovan) {
			//TODO
			delightHistory = DelightHistoryInterface(0x0);
		} else if (network == Network.Ropsten) {
			//TODO
		} else if (network == Network.Rinkeby) {
			//TODO
		} else {
			revert();
		}
	}
}