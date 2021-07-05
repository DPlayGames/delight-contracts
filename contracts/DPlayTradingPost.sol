pragma solidity ^0.5.9;

import "./DPlayTradingPostInterface.sol";
import "./Standard/ERC20.sol";
import "./Standard/ERC721.sol";
import "./Util/SafeMath.sol";

contract DPlayTradingPost is DPlayTradingPostInterface {
	using SafeMath for uint;
	
	ResourceSale[] private resourceSales;
	ItemSale[] private itemSales;
	UniqueItemSale[] private uniqueItemSales;
	
	mapping(address => uint[]) private sellerToResourceSaleIds;
	mapping(address => uint[]) private sellerToItemSaleIds;
	mapping(address => uint[]) private sellerToUniqueItemSaleIds;
	
	// 자원 판매 횟수를 반환합니다.
	function getResourceSaleCount() external view returns (uint) {
		return resourceSales.length;
	}
	
	// Returns the number of item sales.
	// 아이템 판매 횟수를 반환합니다.
	function getItemSaleCount() external view returns (uint) {
		return itemSales.length;
	}
	
	// Returns the number of unique item sales.
	// 유니크 아이템 판매 횟수를 반환합니다.
	function getUniqueItemSaleCount() external view returns (uint) {
		return uniqueItemSales.length;
	}
	
	// 자원을 판매합니다.
	function sellResource(
		address			resourceAddress,
		uint			resourceAmount,
		uint			price,
		string calldata	description
	) external returns (uint) {
		
		// The price must be higher than 0.
		// 판매 가격은 유료여야 합니다.
		require(price > 0);
		
		ERC20 resource = ERC20(resourceAddress);
		
		// 한 개 이상의 자원을 판매해야 합니다.
		require(resourceAmount > 0);
		
		// 판매자가 가진 자원의 양이 판매할 양과 같거나 많아야 합니다.
		require(resource.balanceOf(msg.sender) >= resourceAmount);
		
		// 교역소에 인출을 허락한 자원의 양이 판매할 양과 같거나 많아야 합니다.
		require(resource.allowance(msg.sender, address(this)) >= resourceAmount);
		
		// 교역소에 자원을 이동합니다.
		resource.transferFrom(msg.sender, address(this), resourceAmount);
		
		uint createTime = now;
		
		// Registers the sales info.
		// 판매 정보를 등록합니다.
		uint saleId = resourceSales.push(ResourceSale({
			seller			: msg.sender,
			resourceAddress	: resourceAddress,
			resourceAmount	: resourceAmount,
			price			: price,
			description		: description,
			createTime		: createTime
		})).sub(1);
		
		sellerToResourceSaleIds[msg.sender].push(saleId);
		
		emit SellResource(saleId, price, resourceAddress, resourceAmount, description, createTime);
		
		return saleId;
	}
	
	// Sells items.
	// 아이템을 판매합니다.
	function sellItem(
		address[] calldata	itemAddresses,
		uint[] calldata		itemAmounts,
		uint				price,
		string calldata		description
	) external returns (uint) {
		
		// The price must be higher than 0.
		// 판매 가격은 유료여야 합니다.
		require(price > 0);
		
		// 하나 이상의 아이템을 판매해야 합니다.
		require(itemAddresses.length > 0);
		
		// 아이템 주소의 개수와 아이템 수량의 개수는 같아야 합니다.
		require(itemAddresses.length == itemAmounts.length);
		
		ERC20[] memory items = new ERC20[](itemAddresses.length);
		
		for (uint i = 0; i < itemAddresses.length; i += 1) {
			items[i] = ERC20(itemAddresses[i]);
			
			// 중복되는 아이템이 없어야합니다.
			for (uint j = i + 1; j < itemAddresses.length; j += 1) {
				if (itemAddresses[i] == itemAddresses[j]) {
					revert();
				}
			}
		}
		
		// Data validification
		// 데이터 검증
		for (uint i = 0; i < itemAddresses.length; i += 1) {
			
			// 한 개 이상의 아이템을 판매해야 합니다.
			require(itemAmounts[i] > 0);
			
			// The amount of the seller's items must be equal or more than the amount of the items to be sold.
			// 판매자가 가진 아이템의 양이 판매할 양과 같거나 많아야 합니다.
			require(items[i].balanceOf(msg.sender) >= itemAmounts[i]);
			
			// The amount of the item allowed to be withdrawn by the trading post must be equal or more than the amount of the items to be sold.
			// 교역소에 인출을 허락한 아이템의 양이 판매할 양과 같거나 많아야 합니다.
			require(items[i].allowance(msg.sender, address(this)) >= itemAmounts[i]);
		}
		
		for (uint i = 0; i < itemAddresses.length; i += 1) {
			
			// Moves the items to be sold to the trading post.
			// 교역소에 아이템을 이동합니다.
			items[i].transferFrom(msg.sender, address(this), itemAmounts[i]);
		}
		
		uint createTime = now;
		
		// Registers the sales info.
		// 판매 정보를 등록합니다.
		uint saleId = itemSales.push(ItemSale({
			seller			: msg.sender,
			itemAddresses	: itemAddresses,
			itemAmounts		: itemAmounts,
			price			: price,
			description		: description,
			createTime		: createTime
		})).sub(1);
		
		sellerToItemSaleIds[msg.sender].push(saleId);
		
		emit SellItem(saleId, price, itemAddresses, itemAmounts, description, createTime);
		
		return saleId;
	}
	
	// Sells uniqute items.
	// 유니크 아이템을 판매합니다.
	function sellUniqueItem(
		address[] calldata	itemAddresses,
		uint[] calldata		itemIds,
		uint				price,
		string calldata		description
	) external returns (uint) {
		
		// The price must be higher than 0.
		// 판매 가격은 유료여야 합니다.
		require(price > 0);
		
		// 하나 이상의 아이템을 판매해야 합니다.
		require(itemAddresses.length > 0);
		
		// 아이템 주소의 개수와 아이템 ID의 개수는 같아야 합니다.
		require(itemAddresses.length == itemIds.length);
		
		ERC721[] memory items = new ERC721[](itemAddresses.length);
		
		for (uint i = 0; i < itemAddresses.length; i += 1) {
			items[i] = ERC721(itemAddresses[i]);
			
			// 중복되는 아이템이 없어야합니다.
			for (uint j = i + 1; j < itemAddresses.length; j += 1) {
				if (itemAddresses[i] == itemAddresses[j] && itemIds[i] == itemIds[j]) {
					revert();
				}
			}
		}
		
		// data validification
		// 데이터 검증
		for (uint i = 0; i < itemAddresses.length; i += 1) {
			
			// The seller must own the items to be sold.
			// 판매자가 아이템의 소유자여야 합니다.
			require(items[i].ownerOf(itemIds[i]) == msg.sender);
			
			// The items to be sold must be allowed to be withdrawn by the trading post.
			// 교역소에 인출을 허락한 아이템인지 확인합니다.
			require(
				msg.sender == items[i].getApproved(itemIds[i]) ||
				items[i].isApprovedForAll(msg.sender, address(this)) == true
			);
		}
		
		for (uint i = 0; i < itemAddresses.length; i += 1) {
			
			// Moves the items to be sold to the trading post.
			// 교역소에 아이템을 이동합니다.
			items[i].transferFrom(msg.sender, address(this), itemIds[i]);
		}
		
		uint createTime = now;
		
		// Registers the sales info.
		// 판매 정보를 등록합니다.
		uint saleId = uniqueItemSales.push(UniqueItemSale({
			seller			: msg.sender,
			itemAddresses	: itemAddresses,
			itemIds			: itemIds,
			price			: price,
			description		: description,
			createTime		: createTime
		})).sub(1);
		
		sellerToUniqueItemSaleIds[msg.sender].push(saleId);
		
		emit SellUniqueItem(saleId, price, itemAddresses, itemIds, description, createTime);
		
		return saleId;
	}
	
	// 특정 주소가 자원 판매자인지 확인합니다.
	function checkIsResourceSeller(address addr, uint saleId) external view returns (bool) {
		return resourceSales[saleId].seller == addr;
	}
	
	// Checks if the given address is the item seller.
	// 특정 주소가 아이템 판매자인지 확인합니다.
	function checkIsItemSeller(address addr, uint saleId) external view returns (bool) {
		return itemSales[saleId].seller == addr;
	}
	
	// Checks if the given address is the unique item seller.
	// 특정 주소가 유니크 아이템 판매자인지 확인합니다.
	function checkIsUniqueItemSeller(address addr, uint saleId) external view returns (bool) {
		return uniqueItemSales[saleId].seller == addr;
	}
	
	// 특정 판매자가 판매중인 자원 판매 ID들을 가져옵니다.
	function getResourceSaleIds(address seller) external view returns (uint[] memory) {
		return sellerToResourceSaleIds[seller];
	}
	
	// Gets the sale IDs of the items sold by the given seller.
	// 특정 판매자가 판매중인 아이템 판매 ID들을 가져옵니다.
	function getItemSaleIds(address seller) external view returns (uint[] memory) {
		return sellerToItemSaleIds[seller];
	}
	
	// Gets the sale IDs of the unique items sold by the given seller.
	// 특정 판매자가 판매중인 유니크 아이템 판매 ID들을 가져옵니다.
	function getUniqueItemSaleIds(address seller) external view returns (uint[] memory) {
		return sellerToUniqueItemSaleIds[seller];
	}
	
	// 자원 판매 정보를 반환합니다.
	function getResourceSaleInfo(uint saleId) external view returns (
		address seller,
		address resourceAddress,
		uint resourceAmount,
		uint price,
		string memory description,
		uint createTime
	) {
		
		ResourceSale memory sale = resourceSales[saleId];
		
		return (
			sale.seller,
			sale.resourceAddress,
			sale.resourceAmount,
			sale.price,
			sale.description,
			sale.createTime
		);
	}
	
	// Returns item sales info.
	// 아이템 판매 정보를 반환합니다.
	function getItemSaleInfo(uint saleId) external view returns (
		address seller,
		address[] memory itemAddresses,
		uint[] memory itemAmounts,
		uint price,
		string memory description,
		uint createTime
	) {
		
		ItemSale memory sale = itemSales[saleId];
		
		return (
			sale.seller,
			sale.itemAddresses,
			sale.itemAmounts,
			sale.price,
			sale.description,
			sale.createTime
		);
	}
	
	// Returns the unique item sale info.
	// 유니크 아이템 판매 정보를 반환합니다.
	function getUniqueItemSaleInfo(uint saleId) external view returns (
		address seller,
		address[] memory itemAddresses,
		uint[] memory itemIds,
		uint price,
		string memory description,
		uint createTime
	) {
		
		UniqueItemSale memory sale = uniqueItemSales[saleId];
		
		return (
			sale.seller,
			sale.itemAddresses,
			sale.itemIds,
			sale.price,
			sale.description,
			sale.createTime
		);
	}
	
	// 자원 판매 설명을 수정합니다.
	function updateResourceSaleDescription(uint saleId, string calldata description) external {
		
		ResourceSale storage sale = resourceSales[saleId];
		
		// Checks if the sender is the seller.
		// 판매자인지 확인합니다.
		require(sale.seller == msg.sender);
		
		sale.description = description;
		
		emit UpdateResourceSaleDescription(saleId, description);
	}
	
	// 아이템 판매 설명을 수정합니다.
	function updateItemSaleDescription(uint saleId, string calldata description) external {
		
		ItemSale storage sale = itemSales[saleId];
		
		// Checks if the sender is the seller.
		// 판매자인지 확인합니다.
		require(sale.seller == msg.sender);
		
		sale.description = description;
		
		emit UpdateItemSaleDescription(saleId, description);
	}
	
	// 유니크 아이템 판매 설명을 수정합니다.
	function updateUniqueItemSaleDescription(uint saleId, string calldata description) external {
		
		UniqueItemSale storage sale = uniqueItemSales[saleId];
		
		// Checks if the sender is the seller.
		// 판매자인지 확인합니다.
		require(sale.seller == msg.sender);
		
		sale.description = description;
		
		emit UpdateUniqueItemSaleDescription(saleId, description);
	}
	
	// 판매자의 판매 ID 목록에서 판매 ID를 제거합니다.
	function removeSellerSaleId(uint[] storage sellerSaleIds, uint saleId) internal {
		
		for (uint i = 0; i < sellerSaleIds.length - 1; i += 1) {
			
			if (sellerSaleIds[i] == saleId) {
				
				for (; i < sellerSaleIds.length - 1; i += 1) {
					sellerSaleIds[i] = sellerSaleIds[i + 1];
				}
				
				break;
			}
		}
		
		sellerSaleIds.length -= 1;
	}
	
	// 자원 판매를 취소합니다.
	function cancelResourceSale(uint saleId) external {
		
		ResourceSale memory sale = resourceSales[saleId];
		
		// Checks if the sender is the seller.
		// 판매자인지 확인합니다.
		require(sale.seller == msg.sender);
		
		// 자원을 판매자에게 되돌려줍니다.
		ERC20(sale.resourceAddress).transferFrom(address(this), msg.sender, sale.resourceAmount);
		
		// 판매자의 판매 ID 목록에서 판매 ID를 제거합니다.
		removeSellerSaleId(sellerToResourceSaleIds[msg.sender], saleId);
		
		// Deletes the sale info.
		// 판매 정보를 삭제합니다.
		delete resourceSales[saleId];
		
		emit RemoveResourceSale(saleId);
		emit CancelResourceSale(saleId);
	}
	
	// Cancels an item sale.
	// 아이템 판매를 취소합니다.
	function cancelItemSale(uint saleId) external {
		
		ItemSale memory sale = itemSales[saleId];
		
		// Checks if the sender is the seller.
		// 판매자인지 확인합니다.
		require(sale.seller == msg.sender);
		
		// Returns the items to the seller.
		// 아이템을 판매자에게 되돌려줍니다.
		for (uint i = 0; i < sale.itemAddresses.length; i += 1) {
			ERC20(sale.itemAddresses[i]).transferFrom(address(this), msg.sender, sale.itemAmounts[i]);
		}
		
		// 판매자의 판매 ID 목록에서 판매 ID를 제거합니다.
		removeSellerSaleId(sellerToItemSaleIds[msg.sender], saleId);
		
		// Deletes the sale info.
		// 판매 정보를 삭제합니다.
		delete itemSales[saleId];
		
		emit RemoveItemSale(saleId);
		emit CancelItemSale(saleId);
	}
	
	// Cancels a unique item sale.
	// 유니크 아이템 판매를 취소합니다.
	function cancelUniqueItemSale(uint saleId) external {
		
		UniqueItemSale memory sale = uniqueItemSales[saleId];
		
		// Checks if the sender is the seller.
		// 판매자인지 확인합니다.
		require(sale.seller == msg.sender);
		
		// Returns the items to the seller.
		// 아이템을 판매자에게 되돌려줍니다.
		for (uint i = 0; i < sale.itemAddresses.length; i += 1) {
			ERC721(sale.itemAddresses[i]).transferFrom(address(this), msg.sender, sale.itemIds[i]);
		}
		
		// 판매자의 판매 ID 목록에서 판매 ID를 제거합니다.
		removeSellerSaleId(sellerToUniqueItemSaleIds[msg.sender], saleId);
		
		// Deletes the sale info.
		// 판매 정보를 삭제합니다.
		delete uniqueItemSales[saleId];
		
		emit RemoveUniqueItemSale(saleId);
		emit CancelUniqueItemSale(saleId);
	}
	
	// 자원을 구매합니다.
	function buyResource(uint saleId, uint amount) external payable {
		
		ResourceSale storage sale = resourceSales[saleId];
		
		// 판매량이 구매량보다 크거나 같아야합니다.
		require(sale.resourceAmount >= amount);
		
		// The value must be higher than the price.
		// Eth Value가 가격보다 커야합니다.
		require(msg.value >= sale.price.mul(amount));
		
		// 자원을 구매자에게 전달합니다.
		ERC20(sale.resourceAddress).transferFrom(address(this), msg.sender, amount);
		
		// 판매 자원의 수치를 줄입니다.
		sale.resourceAmount = sale.resourceAmount.sub(amount);
		
		emit ChangeResourceSaleAmount(saleId, sale.resourceAmount);
		
		// Transmits the payment to the seller.
		// 판매자에게 Eth를 전송합니다.
		address(uint160(sale.seller)).transfer(sale.price.mul(amount));
		
		// 모든 자원이 판매되었으면 판매 정보를 삭제합니다.
		if (sale.resourceAmount == 0) {
			
			// 판매자의 판매 ID 목록에서 판매 ID를 제거합니다.
			removeSellerSaleId(sellerToResourceSaleIds[sale.seller], saleId);
			
			delete resourceSales[saleId];
			
			emit RemoveResourceSale(saleId);
		}
		
		emit BuyResource(saleId, amount, msg.sender);
	}
	
	// Buys items.
	// 아이템을 구매합니다.
	function buyItem(uint saleId) external payable {
		
		ItemSale memory sale = itemSales[saleId];
		
		// The value must be higher than the price.
		// Eth Value가 가격보다 커야합니다.
		require(msg.value >= sale.price);
		
		// Delivers the items to the buyer.
		// 아이템을 구매자에게 전달합니다.
		for (uint i = 0; i < sale.itemAddresses.length; i += 1) {
			ERC20(sale.itemAddresses[i]).transferFrom(address(this), msg.sender, sale.itemAmounts[i]);
		}
		
		// Transmits the payment to the seller.
		// 판매자에게 Eth를 전송합니다.
		address(uint160(sale.seller)).transfer(sale.price);
		
		// 판매자의 판매 ID 목록에서 판매 ID를 제거합니다.
		removeSellerSaleId(sellerToItemSaleIds[sale.seller], saleId);
		
		// Deletes the sale info.
		// 판매 정보를 삭제합니다.
		delete itemSales[saleId];
		
		emit RemoveItemSale(saleId);
		
		emit BuyItem(saleId, msg.sender);
	}
	
	// Buys unique items.
	// 유니크 아이템을 구매합니다.
	function buyUniqueItem(uint saleId) external payable {
		
		UniqueItemSale memory sale = uniqueItemSales[saleId];
		
		// The value must be higher than the price.
		// Eth Value가 가격보다 커야합니다.
		require(msg.value >= sale.price);
		
		// Delivers the items to the buyer.
		// 아이템을 구매자에게 전달합니다.
		for (uint i = 0; i < sale.itemAddresses.length; i += 1) {
			ERC721(sale.itemAddresses[i]).transferFrom(address(this), msg.sender, sale.itemIds[i]);
		}
		
		// Transmits the payment to the seller.
		// 판매자에게 Eth를 전송합니다.
		address(uint160(sale.seller)).transfer(sale.price);
		
		// 판매자의 판매 ID 목록에서 판매 ID를 제거합니다.
		removeSellerSaleId(sellerToUniqueItemSaleIds[sale.seller], saleId);
		
		// Deletes the sale info.
		// 판매 정보를 삭제합니다.
		delete uniqueItemSales[saleId];
		
		emit RemoveUniqueItemSale(saleId);
		
		emit BuyUniqueItem(saleId, msg.sender);
	}
}