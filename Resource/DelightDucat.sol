pragma solidity ^0.5.9;

import "../DelightResource.sol";
import "../Util/SafeMath.sol";

contract DelightDucat is DelightResource {
	using SafeMath for uint;
	
	constructor() public {
		
		_name = "Delight Ducat";
		_symbol = "DD";
		_decimals = 18;
		_totalSupply = 100000000 * (10 ** uint(_decimals));
		
		balances[msg.sender] = _totalSupply;
		emit Transfer(address(0x0), msg.sender, _totalSupply);
	}
}