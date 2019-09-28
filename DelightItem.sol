pragma solidity ^0.5.9;

import "./Standard/ERC20.sol";
import "./Standard/ERC165.sol";
import "./Util/NetworkChecker.sol";
import "./Util/SafeMath.sol";

contract DelightItem is ERC20, ERC165, NetworkChecker {
	using SafeMath for uint;
	
	// The two addresses below are the addresses of the trusted smart contract, and don't need to be allowed.
	// 아래 두 주소는 신뢰하는 스마트 계약의 주소로 허락받을 필요가 없습니다.
	
	// Delight item manager's address.
	// Delight 아이템 관리자 주소
	address public delightItemManager;
	
	// The address of DPlay trading post
	// DPlay 교역소 주소
	address public dplayTradingPost;
	
	constructor() NetworkChecker() public {
		
		if (network == Network.Mainnet) {
			//TODO
		}
		
		else if (network == Network.Kovan) {
			dplayTradingPost = address(0xEcDc20F027fF277Dc10DE039d5409D433Bec5eE3);
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
		
		balances[msg.sender] = _totalSupply;
		
		emit Transfer(address(0), msg.sender, _totalSupply);
	}
	
	function setDelightItemManagerOnce(address addr) external {
		// The address has to be empty.
		// 비어있는 주소인 경우에만
		require(delightItemManager == address(0));
		
		delightItemManager = addr;
	}
	
	// Token information
	// 토큰 정보 
	string internal _name;
	string internal _symbol;
	uint private _totalSupply = 0;
	
	uint8 constant private DECIMALS = 0;
	
	mapping(address => uint) internal balances;
	mapping(address => mapping(address => uint)) private allowed;
	
	// Creates an item and gives to a specific user.
	// 아이템을 제조하여 특정 유저에게 전달합니다.
	function assemble(address to, uint amount) external {
		
		// This function can only be used by the Delight item manager.
		// Delight 아이템 관리자만 사용할 수 있는 함수입니다.
		require(msg.sender == delightItemManager);
		
		balances[to] = balances[to].add(amount);
		
		emit Transfer(delightItemManager, to, amount);
	}
	
	// Dismantles an item.
	// 아이템을 분해합니다.
	function disassemble(uint amount) external {
		
		// This function can only be used by the Delight item manager.
		// Delight 아이템 관리자만 사용할 수 있는 함수입니다.
		require(msg.sender == delightItemManager);
		
		balances[delightItemManager] = balances[delightItemManager].sub(amount);
		
		emit Transfer(delightItemManager, address(0), amount);
	}
	
	// Checks if the address is misued.
	// 주소를 잘못 사용하는 것인지 체크 
	function checkAddressMisused(address target) internal view returns (bool) {
		return
			target == address(0) ||
			target == address(this);
	}
	
	//ERC20: Returns the name of the token.
	//ERC20: 토큰의 이름 반환
	function name() external view returns (string memory) {
		return _name;
	}
	
	//ERC20: Returns the symbol of the token.
	//ERC20: 토큰의 심볼 반환
	function symbol() external view returns (string memory) {
		return _symbol;
	}
	
	//ERC20: Returns the decimals of the token.
	//ERC20: 토큰의 소수점 반환
	function decimals() external view returns (uint8) {
		return DECIMALS;
	}
	
	//ERC20: Returns the total number of tokens.
	//ERC20: 전체 토큰 수 반환
	function totalSupply() external view returns (uint) {
		return _totalSupply;
	}
	
	//ERC20: Returns the number of tokens of a specific user.
	//ERC20: 특정 유저의 토큰 수를 반환합니다.
	function balanceOf(address user) external view returns (uint balance) {
		return balances[user];
	}
	
	//ERC20: Transmits tokens to a specific user.
	//ERC20: 특정 유저에게 토큰을 전송합니다.
	function transfer(address to, uint amount) external returns (bool success) {
		
		// Blocks misuse of an address.
		// 주소 오용 차단
		require(checkAddressMisused(to) != true);
		
		require(amount <= balances[msg.sender]);
		
		balances[msg.sender] = balances[msg.sender].sub(amount);
		balances[to] = balances[to].add(amount);
		
		emit Transfer(msg.sender, to, amount);
		
		return true;
	}
	
	//ERC20: Grants rights to send the amount of tokens to the spender.
	//ERC20: spender에 amount만큼의 토큰을 보낼 권리를 부여합니다.
	function approve(address spender, uint amount) external returns (bool success) {
		
		allowed[msg.sender][spender] = amount;
		
		emit Approval(msg.sender, spender, amount);
		
		return true;
	}
	
	//ERC20: Returns the quantity of tokens to the spender
	//ERC20: spender가 인출하도록 허락 받은 토큰의 양을 반환합니다.
	function allowance(address user, address spender) external view returns (uint remaining) {
		
		if (
		// Delight와 DPlay 교역소는 모든 토큰을 전송할 수 있습니다.
		spender == delightItemManager ||
		spender == dplayTradingPost) {
			return balances[user];
		}
		
		return allowed[user][spender];
	}
	
	//ERC20: The allowed spender sends the "amount" of tokens from the "from" to the "to".
	//ERC20: 허락된 spender가 from으로부터 amount만큼의 토큰을 to에게 전송합니다.
	function transferFrom(address from, address to, uint amount) external returns (bool success) {
		
		// Blocks misuse of an address.
		// 주소 오용 차단
		require(checkAddressMisused(to) != true);
		
		require(amount <= balances[from]);
		
		require(
			// Delight and DPlay trading post can transmit any tokens.
			// Delight와 DPlay 교역소는 모든 토큰을 전송할 수 있습니다.
			msg.sender == delightItemManager ||
			msg.sender == dplayTradingPost ||
			
			amount <= allowed[from][msg.sender]
		);
		
		balances[from] = balances[from].sub(amount);
		balances[to] = balances[to].add(amount);
		
		if (
			msg.sender != delightItemManager &&
			msg.sender != dplayTradingPost
		) {
			allowed[from][msg.sender] = allowed[from][msg.sender].sub(amount);
		}
		
		emit Transfer(from, to, amount);
		
		return true;
	}
	
	//ERC165: Checks if the given interface has been implemented.
	//ERC165: 주어진 인터페이스가 구현되어 있는지 확인합니다.
	function supportsInterface(bytes4 interfaceID) external view returns (bool) {
		return
			// ERC165
			interfaceID == this.supportsInterface.selector ||
			// ERC20
			interfaceID == 0x942e8b22 ||
			interfaceID == 0x36372b07;
	}
}
