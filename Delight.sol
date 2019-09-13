pragma solidity ^0.5.9;

import "./DelightBuildingManager.sol";
import "./DelightArmyManager.sol";
import "./DelightItemManager.sol";
import "./Util/SafeMath.sol";

contract Delight is DelightBuildingManager, DelightArmyManager, DelightItemManager {
	using SafeMath for uint;
}