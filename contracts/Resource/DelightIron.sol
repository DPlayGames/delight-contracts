pragma solidity ^0.5.9;

import "../DelightResource.sol";
import "../Util/SafeMath.sol";

contract DelightIron is DelightResource {
	using SafeMath for uint;
	
	constructor(address dplayTradingPost) DelightResource(dplayTradingPost) public {
		
		_name = "Delight Iron";
		_symbol = "DI";
		_totalSupply = 50000000;
		
		balances[msg.sender] = _totalSupply;
		emit Transfer(address(0), msg.sender, _totalSupply);
	}
}