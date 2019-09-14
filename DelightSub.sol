pragma solidity ^0.5.9;

import "./DelightBase.sol";
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
}