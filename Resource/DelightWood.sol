pragma solidity ^0.5.9;

import "../DelightResource.sol";
import "../Util/SafeMath.sol";

contract DelightWood is DelightResource {
	using SafeMath for uint;
	
	constructor() public {
		
		_name = "Delight Wood";
		_symbol = "DW";
		_totalSupply = 100000000;
		
		balances[msg.sender] = _totalSupply;
		emit Transfer(address(0), msg.sender, _totalSupply);
	}
}