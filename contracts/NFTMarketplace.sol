// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

/**
 * @title NFTMarkeplace
 * @author Thomas Heim 
 * @notice A smart contract that enables users to discover, create, purchase, and sell NFTs.
 * @dev This smart contract is using ERC721 standard from OpenZeppelin. 
 */

contract NFTMarketplace is ERC721URIStorage {
  using Counters for Counters.Counter;

  Counters.Counter private _tokenIds;
  Counters.Counter private _itemsSold;

    uint256 listingPrice  = 0.025 ether;
    address payable owner;
   
    /** 
     * @dev Keeping up with all the items that have been created.
     * Pass in the integer which is the item id and it returns a market item.
     * To fetch a market item, we only need the item id.
     */
    mapping (uint256 => MarketItem) private idToMarketItem;
    
    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }
    
     /** 
     * @dev Have an event for when a market item is created.
     * This event matches the MarketItem.     
     */
    event MarketItemCreated (
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

  /** 
   * @dev Set the owner as the msg.sender.
   * Owner of contract is the one deploying it.
  */
  constructor() ERC721("Metaverse Tokens","METT"){
    owner = payable(msg.sender); 
  }

    /** 
     * @dev Only owner of contract can update the listing price.
    */
    function updateListingPrice(uint _listingPrice) public payable {
        require(owner == msg.sender, "Only marketplace owner can update the listing price");
        listingPrice = _listingPrice;
    }

    /** 
     * @dev View function that can display listing price for the NFTs in the frontend. 
    */
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    /** 
     * @dev Mints a token and lists it in the marketplace. 
     */
    function createToken(string memory tokenURI, uint256 price) public payable returns (uint) {
        _tokenIds.increment();

        uint256 newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        createMarketItem(newTokenId, price);

        return newTokenId; 
    }

    /** 
     * @dev This function works together with the createToken function above.
     * Require a certain CONDITION, in this case price greater than 0.
     * Require that the users sending in the transaction is sending in the correct amount.
     * Create the mapping for the market items.
     * Payable(address(0)) is the owner.
     * Currently there's no owner as the seller is putting it to market so it's an empty address.
     * Last value  is boolean for sold, its false because we just put it so it's not sold yet.
     * This is creating the first market item.
     */
    function createMarketItem(uint256 tokenId, uint256 price) private {
        require(price > 0, "Price must be at least 1");
        require(msg.value == listingPrice, "Price must be equal to listing price");

        idToMarketItem[tokenId]= MarketItem(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        );

        _transfer(msg.sender, address(this), tokenId);
        emit MarketItemCreated(tokenId, msg.sender, address(this), price, false);
    }

    /** 
     * @dev This function makes it possible for only a buyer of an NFT to resell the NFT by checking if the NFT is yours and updating the properties of that NFT. 
    */
    function resellToken(uint256 tokenId, uint256 price) public payable {
        require(idToMarketItem[tokenId].owner == msg.sender, "Only item owner can perform this operation");
        require(msg.value == listingPrice, "Price must be equal to listing price");

        idToMarketItem[tokenId].sold = false;
        idToMarketItem[tokenId].price = price;
        idToMarketItem[tokenId].seller = payable(msg.sender);
        idToMarketItem[tokenId].owner = payable(address(this));

       
        _itemsSold.decrement();
        _transfer(msg.sender, address(this), tokenId);
    }
    
    /** 
     * @dev Creates the sale of a marketplace item  checking if the NFT is yours and updating.
     * Transfers ownership of the item, as well as funds between parties  
    */
    function createMarketSale(uint256 tokenId) public payable {
     uint price = idToMarketItem[tokenId].price;

     require(msg.value == price, "Please submit the asking price in order to complete the purchase");

     idToMarketItem[tokenId].owner = payable(msg.sender);
     idToMarketItem[tokenId].sold = true;
     idToMarketItem[tokenId].seller = payable(address(0));

     _itemsSold.increment();

     _transfer(address(this), msg.sender, tokenId);

     payable(owner).transfer(listingPrice);
     payable(idToMarketItem[tokenId].seller).transfer(msg.value);
    }
    
    /** 
     * @dev Returns all unsold market items.
     * looping over the number of items created and incremnet that number if we have an empty address.
     * Empty array called items.
     * The type of the element in the array is marketitem, and the unsolditemcount is the lenght.
    */
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _tokenIds.current();
        uint256 unsoldItemCount = _tokenIds.current() - _itemsSold.current();
        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);

        for(uint256 i = 0; i < itemCount; i++) {
            if(idToMarketItem[i+1].owner == address(this)){
                uint256 currentId = i + 1;

                MarketItem storage currentItem = idToMarketItem[currentId];

                items[currentIndex] = currentItem;

                currentIndex +=1;
            }
        }

        return items;
   }
    
    /** 
     * @dev Returns only items that a user has purchased and the number of items that they own.
    */
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _tokenIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++){
            if(idToMarketItem[i+1].owner == msg.sender){
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);

        for(uint256 i = 0; i < totalItemCount; i++) {
            if(idToMarketItem[i+1].owner == msg.sender) {
                uint256 currentId = i + 1;

                MarketItem storage currentItem = idToMarketItem[currentId];

                items[currentIndex] = currentItem;

                currentIndex +=1;
            }
        }

        return items;
    }
    /** 
     * @dev Returns only items a user has listed.
    */
    function fetchItemsListed() public view returns (MarketItem[] memory) {
      uint256 totalItemCount = _tokenIds.current();
      uint256 itemCount = 0;
      uint256 currentIndex = 0;

      for (uint256 i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].seller == msg.sender) {
          itemCount += 1;
        }
      }

      MarketItem[] memory items = new MarketItem[](itemCount);
      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].seller == msg.sender) {
          uint currentId = i + 1;
          MarketItem storage currentItem = idToMarketItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      
      return items;
    }
}
 