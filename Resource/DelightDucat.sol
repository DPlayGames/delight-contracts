pragma solidity ^0.5.9;

import "../DelightResource.sol";
import "../Util/SafeMath.sol";

contract DelightDucat is DelightResource {
	using SafeMath for uint;
	
	constructor() public {
		
		_name = "Delight Ducat";
		_symbol = "DD";
		_totalSupply = 100000000;
		
		balances[msg.sender] = _totalSupply;
		emit Transfer(address(0), msg.sender, _totalSupply);
	}
}