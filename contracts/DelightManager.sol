pragma solidity ^0.5.9;

import "./DelightBase.sol";
import "./DelightResource.sol";
import "./DelightInfoInterface.sol";
import "./Util/SafeMath.sol";

contract DelightManager is DelightBase {
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
	
	constructor(
		DelightInfoInterface _info,
		DelightResource _wood,
		DelightResource _stone,
		DelightResource _iron,
		DelightResource _ducat
	) public {
		
		// Delight basic information
		// Delight 기본 정보
		info	= _info;

		// Resources
		// 자원들
		wood	= _wood;
		stone	= _stone;
		iron	= _iron;
		ducat	= _ducat;
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
