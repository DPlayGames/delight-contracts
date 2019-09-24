pragma solidity ^0.5.9;

import "../DelightResource.sol";
import "../Util/SafeMath.sol";

contract DelightStone is DelightResource {
	using SafeMath for uint;
	
	constructor() public {
		
		_name = "Delight Stone";
		_symbol = "DS";
		_totalSupply = 10000000;
		
		balances[msg.sender] = _totalSupply;
		emit Transfer(address(0), msg.sender, _totalSupply);
	}
}