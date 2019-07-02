pragma solidity ^0.5.9;

contract NetworkChecker {
	
	address constant private MAINNET_MILESTONE_ADDRESS = 0xa6e90A28F446D3639916959B6087F68D9B83fca9;
	address constant private KOVAN_MILESTONE_ADDRESS = 0x9a6Dc2a58256239500D96fb6f13D73b70C3d88f9;
	address constant private ROPSTEN_MILESTONE_ADDRESS = 0x212cC55dd760Ec5352185A922c61Ac41c8dDB197;
	address constant private RINKEBY_MILESTONE_ADDRESS = 0x54d1991a37cbA30E5371F83e8c2B1F762c7096c2;
	
	enum Network {
		Mainnet,
		Kovan,
		Ropsten,
		Rinkeby,
		Unknown
	}
	
	Network public network;
	
	// Checks if the given address is a smart contract.
	// 주어진 주소가 스마트 계약인지 확인합니다.
	function checkIsSmartContract(address addr) private view returns (bool) {
		uint32 size;
		assembly { size := extcodesize(addr) }
		return size > 0;
	}
	
	constructor() public {
		
		// Checks if the contract runs on the main network.
		// Main 네트워크인지 확인합니다.
		if (checkIsSmartContract(MAINNET_MILESTONE_ADDRESS) == true) {
			(bool success, ) = MAINNET_MILESTONE_ADDRESS.call(abi.encodeWithSignature("helloMainnet()"));
			if (success == true) {
				network = Network.Mainnet;
				return;
			}
		}
		
		// Checks if the contract is in the Kovan network.
		// Kovan 네트워크인지 확인합니다.
		if (checkIsSmartContract(KOVAN_MILESTONE_ADDRESS) == true) {
			(bool success, ) = KOVAN_MILESTONE_ADDRESS.call(abi.encodeWithSignature("helloKovan()"));
			if (success == true) {
				network = Network.Kovan;
				return;
			}
		}
		
		// Checks if the contract is in the Ropsten network.
		// Ropsten 네트워크인지 확인합니다.
		if (checkIsSmartContract(ROPSTEN_MILESTONE_ADDRESS) == true) {
			(bool success, ) = ROPSTEN_MILESTONE_ADDRESS.call(abi.encodeWithSignature("helloRopsten()"));
			if (success == true) {
				network = Network.Ropsten;
				return;
			}
		}
		
		// Checks if the contract is in the Rinkeby network.
		// Rinkeby 네트워크인지 확인합니다.
		if (checkIsSmartContract(RINKEBY_MILESTONE_ADDRESS) == true) {
			(bool success, ) = RINKEBY_MILESTONE_ADDRESS.call(abi.encodeWithSignature("helloRinkeby()"));
			if (success == true) {
				network = Network.Rinkeby;
				return;
			}
		}
		
		// The network is unknown.
		// 알 수 없는 네트워크
		network = Network.Unknown;
	}
}
