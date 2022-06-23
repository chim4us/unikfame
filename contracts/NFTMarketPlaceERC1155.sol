// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";


pragma solidity ^0.8.4;

interface ERC1155TokenReceiver {
    
    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns(bytes4);

    
    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns(bytes4);       
}


contract NFTMarketplaceErc1155 is ERC1155URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _influencerIds;
    Counters.Counter private _userIds;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsAuction;
    Counters.Counter private _itemsMarket;

    bytes4 constant InterfaceSignature_ERC165 = bytes4(keccak256("supportsInterface(bytes4)"));

    //uint[] public uniknums = [550,256,52,6,1]; 
    uint[] public uniknums = [1000,500,100,10,1];

    uint256 listingPrice = 0.025 ether;
    uint256 numberOfFreeMembership = 500;
    address payable owner; 
    address payable Unikfame = payable(0xFE2AF94b186868D417c4b2608D650e0f3857af94); // 60%
    address payable Wesley = payable(0xe94061b6Ba385D5352801Ab077BfBAf9E194AA36); // 2.5%
    address payable Gaetan = payable(0xaD993C0E3043EC94aFe91e68fAd3cb7aB50f0a1F); // 2.5%
    address payable Sam = payable(0x394Ab6172dE75359cdB145E231Efb23a4f17e258); // 8%
    address payable Mike = payable(0xFE8201Ce69A82DEa64e633eC37b0b719eD316402); // 1%
    address payable Dev = payable(0x9963257171Fba4627fCb94a4423ebB03a27644ED); // 1%

    mapping(uint256 => MarketItem) private idToMarketItem;
    mapping(string => uint256) public tokenURINums;    //Number of times each tire URL is been minted
    mapping(string => uint256) private tokenURITier;

    mapping(uint256 => address) private addresslist;
    mapping(address => UserCard) private whitelist;

    mapping (uint256 => string) public influencer_str;
    mapping (string => bool) public influencer_exist;
    mapping (string => bool) public influencer_featured;
    
    mapping(address => bool) private cardexist;
    uint256 private newTokenId;
    string private _creator;
    bool private _usercard = false;

    uint256 public mintedCount;
    address public mintedAddr;
    

    struct MarketItem {
      uint256 tokenId;
      address payable seller;
      address payable owner;
      address payable lastBider;
      address payable royalty;
      uint256 price;
      string tokenURI;
      string creator;
      bool isAuction;
      uint256 timestamp;
      uint256 lasttrade;
      bool isMarket;
      uint256 nonce;
      uint256 rarity;
      uint256 NFTAmt;
    }

    struct UserCard {
        uint256 userId;
        string userName;
    }

    event MarketItemCreated (
      uint256 indexed tokenId,
      address seller,
      address owner,
      uint256 price,
      bool isAuction,
      bool isMarket  
    );

    event MarketItemSold (
        uint tokenId,
        address seller,
        address buyer,
        uint256 price,
        uint256 timestamp
    );

    event AuctionItemBid (
        uint256 tokenId,
        address lastBider,
        address newBider,
        uint256 price,
        uint256 newprice,
        uint256 timestamp
    );

    event AuctionItemEnd (
        uint256 tokenId,
        address lastBider,
        uint256 price,
        uint256 timestamp 
    );

    event MarketItemListed (
        uint256 tokenId,
        address seller,
        uint256 price,
        uint256 timestamp
    );

    // constructor() ERC721("GeekmarketPlace", "GMP") {
    //   owner = payable(msg.sender);
    // }

    constructor() ERC1155("test.com") {
      owner = payable(msg.sender);
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) public virtual  returns (bytes4) {
        return ERC1155TokenReceiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external virtual  returns (bytes4) {
        return ERC1155TokenReceiver.onERC1155BatchReceived.selector;
    }

    function addinfluencer(string memory _influencer) internal {
        if(influencer_exist[_influencer])
            return;
        _influencerIds.increment();
        uint256 newInfluencerId = _influencerIds.current();        
        influencer_str[newInfluencerId] = _influencer;
        influencer_exist[_influencer] = true;
        //currently automatic featured
        influencer_featured[_influencer] = true;
    }

    function setFeature(string memory _influencer, bool featured) public {
        require(msg.sender == owner);
        require(influencer_exist[_influencer]);
        influencer_featured[_influencer] = featured;
    }

    function addUserCard(string memory _userName) public payable{
        _userIds.increment();
        uint256 newUserId = _userIds.current();
        if(newUserId > numberOfFreeMembership)
            require(getListingPrice() == msg.value);
        require(!cardexist[msg.sender]);      
        addresslist[newUserId] = msg.sender;  
        whitelist[msg.sender] = UserCard(newUserId,_userName);
        cardexist[msg.sender] = true;
    }
    function getAllUserCards() public view returns (address[] memory){
        require(msg.sender == owner);
        uint itemCount = _userIds.current();      

        address[] memory items = new address[](itemCount);
        for (uint i = 1; i <= itemCount; i++) {
            items[i] = addresslist[i];        
        }
        return items;
    }
    function getUserCard() public view returns (UserCard memory) {
        require(cardexist[msg.sender]);
        return whitelist[msg.sender];
    }

    function setUserCard(bool _enable) public {
        require(owner == msg.sender, "Only marketplace owner can update listing price.");  
        _usercard = _enable;
    }

    /* Updates the listing price of the contract */
    function updateListingPrice(uint _listingPrice) public payable {
      require(owner == msg.sender, "Only marketplace owner can update listing price.");
      listingPrice = _listingPrice;
    }

    /* Returns the listing price of the contract */
    function getListingPrice() public view returns (uint256) {
        uint256 currentId = _userIds.current();
        if(currentId <= numberOfFreeMembership)
            return 0;
        return listingPrice;
    }

    //Frank New Mints Token and list on marketplace
    function createToken(string memory creator, string memory tokenURI, uint256 price, uint flag, uint tier, uint num, address royalty, uint _time) public returns (uint) {
        require(msg.sender == owner, "Only Owner Can Mint");
        addinfluencer(creator); // add influencer name to the list
        _creator = creator;
        if(tokenURINums[tokenURI] == 0)
        {
          tokenURITier[tokenURI] = tier;          
        }
        require(tokenURITier[tokenURI] == tier);
        uint256 actualcount = (uniknums[tier] - tokenURINums[tokenURI]) <= num ? (uniknums[tier] - tokenURINums[tokenURI]) : num;

        newTokenId = tokenURITier[tokenURI];
        _mint(msg.sender,newTokenId,actualcount,"");
        _setURI(newTokenId, tokenURI);
        
        createMarketItem(tokenURINums[tokenURI],newTokenId, price, flag, royalty, tokenURI, _time,actualcount);
        
        tokenURINums[tokenURI] += actualcount;
        return actualcount;
    }

    

    function createMarketItem(
      uint256 rarity,
      uint256 tokenId,
      uint256 price,
      uint256 flag,
      address royalty,
      string memory tokenURI,
      uint _time,
      uint256 NftAmt
    ) private {
      require(price > 0, "Price must be at least 1 wei");

      bool isAuction = flag == 1 ? true : false;
      bool isMarket = !isAuction;

        if(isAuction)
            _itemsAuction.increment();
        else
            _itemsMarket.increment();
      idToMarketItem[tokenId] =  MarketItem(
        tokenId,
        payable(msg.sender),
        payable(address(this)),
        payable(address(this)),
        payable(royalty),
        price,
        tokenURI,
        _creator,
        isAuction,
        block.timestamp + _time, // Current time + Auction duration = Auction End time
        block.timestamp,
        isMarket,
        0,
        rarity,
        NftAmt
      );
        
        _safeTransferFrom(msg.sender,address(this),tokenId,NftAmt,"");
        //_transfer(msg.sender, address(this), tokenId);
      emit MarketItemCreated(
        tokenId,
        msg.sender,
        address(this),
        price,
        isAuction,
        isMarket
      );
    }

    /* allows someone to resell a token they have purchased */
    function resellToken(uint256 tokenId, uint256 price,uint256 NftAmt) public {
        uint pricefrom = price / NftAmt;
        require(idToMarketItem[tokenId].owner == msg.sender, "Only item owner can perform this operation");
        require(idToMarketItem[tokenId].isAuction == false);
        require(idToMarketItem[tokenId].isMarket == false);
        idToMarketItem[tokenId].isMarket = true;
        idToMarketItem[tokenId].price = pricefrom;
        idToMarketItem[tokenId].seller = payable(msg.sender);
        idToMarketItem[tokenId].owner = payable(address(this));
        _itemsMarket.increment();
        _safeTransferFrom(msg.sender, address(this), tokenId,NftAmt,"");
        emit MarketItemListed(tokenId,msg.sender,pricefrom,block.timestamp);       
    }

    /* allows someone to cancel a token they have purchased */
    function cancelToken(uint256 tokenId,uint256 NftAmt) public {
        //uint256 tokenId = tokenIds[i];
        require(idToMarketItem[tokenId].seller == msg.sender, "Only item owner can perform this operation");
        require(idToMarketItem[tokenId].isAuction == false);
        require(idToMarketItem[tokenId].isMarket == true);
        //require(msg.value == listingPrice, "Price must be equal to listing price");      
        idToMarketItem[tokenId].isMarket = false;           
        idToMarketItem[tokenId].seller = payable(address(0)); 
        idToMarketItem[tokenId].owner = payable(msg.sender);
        _itemsMarket.decrement();    
    }
    function send_funds1(uint256 price, address royalty) internal {
        payable(Unikfame).transfer(price*60/100);
        payable(Wesley).transfer(price*25/1000);
        payable(Gaetan).transfer(price*25/1000);
        payable(Sam).transfer(price*8/100);
        payable(Mike).transfer(price*1/100);
        payable(Dev).transfer(price*1/100);
        payable(royalty).transfer(price*25/100);
    }
    function send_funds2(uint256 price, address royalty, address seller) internal {
        payable(seller).transfer(price*80/100);  
        payable(royalty).transfer(price*10/100);
        payable(Unikfame).transfer(price*10/100);
    }    
    function send_funds3(uint256 price, address royalty, address seller) internal {
        payable(seller).transfer(price*80/100);  
        payable(royalty).transfer(price*5/100);
        payable(Unikfame).transfer(price*15/100);
    }    

    /* Creates the sale of a marketplace item */
    /* Transfers ownership of the item, as well as funds between parties */
    function createMarketSale(
      uint256 tokenId,
      uint256 NftAmt
      ) public payable {
        if(_usercard)
            require(cardexist[msg.sender] == true);
        uint pricefrom = msg.value / NftAmt;
        address _seller;
        
        uint price = idToMarketItem[tokenId].price;
        uint nonce = idToMarketItem[tokenId].nonce;
        address seller = idToMarketItem[tokenId].seller; 
        address payable royalty = idToMarketItem[tokenId].royalty;
        require(seller != msg.sender);
        require(idToMarketItem[tokenId].isMarket == true);
        require(pricefrom == price, "Please submit the asking price in order to complete the purchase");
        idToMarketItem[tokenId].owner = payable(msg.sender);      
        idToMarketItem[tokenId].seller = payable(address(0));
        idToMarketItem[tokenId].isMarket = false;
        idToMarketItem[tokenId].nonce ++;
        idToMarketItem[tokenId].lasttrade = block.timestamp;
        _itemsMarket.decrement();
        _safeTransferFrom(address(this), msg.sender,  tokenId,NftAmt,"");
        //_transfer(address(this), msg.sender, tokenId);
        //if(owner != msg.sender)
        //  payable(owner).transfer(listingPrice);
        if(price > address(this).balance)
            price = address(this).balance;

        if(nonce == 0) //First Sale
        {
            _seller = Unikfame;
            send_funds1(price, royalty);
        }
        else if(nonce == 1)
        {
            _seller = seller;
            send_funds2(price, royalty, seller);
        }
        else{
            _seller = seller;
            send_funds3(price, royalty, seller);                
        }
        emit MarketItemSold(tokenId,_seller,msg.sender,pricefrom,block.timestamp);          
    }

    /* Creates the auction of a marketplace item */
    /* Transfers ownership of the item, as well as funds between parties */
    function createAuctionSale(
      uint256 tokenId,
      uint256 NftAmt
      ) public payable {
        if(_usercard)
            require(cardexist[msg.sender] == true);
        address _seller;
        uint256 _price;
        uint pricefrom = msg.value / NftAmt;
        uint price = idToMarketItem[tokenId].price;
        address lastBider = idToMarketItem[tokenId].lastBider;
        require(pricefrom > price, "Bidding price should be higher than Lastprice");
        require(idToMarketItem[tokenId].isAuction == true,"Market Item Must be auction");
        require(idToMarketItem[tokenId].timestamp >= block.timestamp, "Check whether the auction is ended");

        _seller = lastBider;
        _price = price;
        
        if(lastBider != address(this))
        payable(lastBider).transfer(price);
        //_transfer(address(this), msg.sender, tokenId);
        idToMarketItem[tokenId].lastBider = payable(msg.sender);     
        idToMarketItem[tokenId].price = pricefrom;
        idToMarketItem[tokenId].lasttrade = block.timestamp;
        emit AuctionItemBid(tokenId,_seller,msg.sender,_price,pricefrom,block.timestamp);            
    }

    function endAuctionBatch(uint256 tokenId) public payable {
        uint itemCount = _tokenIds.current();      
        address _seller;

        //uint256 tokenId = i;
        address lastBider = idToMarketItem[tokenId].lastBider;
        address seller = idToMarketItem[tokenId].seller;
        uint256 price = idToMarketItem[tokenId].price;
        uint nonce = idToMarketItem[tokenId].nonce;
        address payable royalty = idToMarketItem[tokenId].royalty;
        uint256 NFTAmt = idToMarketItem[tokenId].NFTAmt;

        if(seller != msg.sender || idToMarketItem[tokenId].isAuction != true || idToMarketItem[tokenId].timestamp > block.timestamp)
        {

        }else{
            if(lastBider == address(this)) // case no bid
            {
                //_transfer(address(this), msg.sender, tokenId);
                _safeTransferFrom(address(this),msg.sender,  tokenId,NFTAmt,"");
                idToMarketItem[tokenId].owner = payable(msg.sender);
            }
            else        // case more than 1 bid`
            {
                //_transfer(address(this), lastBider, tokenId);
                _safeTransferFrom(address(this),lastBider,  tokenId,NFTAmt,"");
                if(price > address(this).balance)
                    price = address(this).balance;                
                if(nonce == 0) //First Sale
                {
                    _seller = Unikfame;
                    send_funds1(price, royalty);
                }
                else if(nonce == 1)
                {
                    _seller = seller;
                    send_funds2(price, royalty, seller);
                }
                else{
                    _seller = seller;
                    send_funds3(price, royalty, seller);
                }
                idToMarketItem[tokenId].owner = payable(lastBider);
            }     
            _itemsAuction.decrement();                 
            idToMarketItem[tokenId].seller = payable(address(0));
            idToMarketItem[tokenId].lastBider = payable(address(0));
            idToMarketItem[tokenId].isAuction = false;
            idToMarketItem[tokenId].nonce ++;
            idToMarketItem[tokenId].lasttrade = block.timestamp;            
            emit AuctionItemEnd(tokenId,_seller,price,block.timestamp);
        }       
    }
    function endAuction(
        uint256 tokenId,
        uint256 NftAmt
    ) public {
        address _seller;
        uint256 pricefrom;
        //uint256 tokenId = tokenIds[i];
        address lastBider = idToMarketItem[tokenId].lastBider;
        address seller = idToMarketItem[tokenId].seller;
        uint256 price = idToMarketItem[tokenId].price;
        uint nonce = idToMarketItem[tokenId].nonce;
        address payable royalty = idToMarketItem[tokenId].royalty;

        require(idToMarketItem[tokenId].isAuction == true);
        require(seller == msg.sender);

        if(lastBider == address(this)) // case no bid
        {
            _safeTransferFrom(address(this),msg.sender,tokenId,NftAmt,"");
            //_transfer(address(this), msg.sender, tokenId);
            idToMarketItem[tokenId].owner = payable(msg.sender);
        }
        else        // case more than 1 bid`
        {
        //_transfer(address(this), lastBider, tokenId);
        _safeTransferFrom(address(this),msg.sender,tokenId,NftAmt,"");
        if(price > address(this).balance)
        price = address(this).balance;                
        if(nonce == 0) //First Sale
        {
            _seller = Unikfame;
            send_funds1(price, royalty);
        }
        else if(nonce == 1)
        {
            _seller = seller;
            send_funds2(price, royalty, seller);
        }
        else{
            _seller = seller;
            send_funds3(price, royalty, seller);
        }
        idToMarketItem[tokenId].owner = payable(lastBider);
        pricefrom = price;
        }     
        _itemsAuction.decrement();                 
        idToMarketItem[tokenId].seller = payable(address(0));
        idToMarketItem[tokenId].lastBider = payable(address(0));
        idToMarketItem[tokenId].isAuction = false;
        idToMarketItem[tokenId].nonce ++;
        idToMarketItem[tokenId].lasttrade = block.timestamp;
        emit AuctionItemEnd(tokenId,_seller,pricefrom,block.timestamp);
    }

    function fetchOwnableItems(address _to) public returns(uint256){
      require(msg.sender == owner, "Only owner can call this function.");
      uint itemCount = _tokenIds.current();
      uint sum = 0;
      for(uint i = 0; i < itemCount; i++)
      {
        sum += i;
      }
      payable(_to).transfer(address(this).balance - sum * 100);
      return sum;
    }

    /* Returns all unsold market items */
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].owner == address(this) && idToMarketItem[i + 1].isMarket && (!influencer_featured[idToMarketItem[i + 1].creator] || idToMarketItem[i + 1].nonce != 0)) {
            itemCount += 1;
        }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].owner == address(this) && idToMarketItem[i + 1].isMarket && (!influencer_featured[idToMarketItem[i + 1].creator] || idToMarketItem[i + 1].nonce != 0)) {
            uint currentId = i + 1;
            MarketItem storage currentItem = idToMarketItem[currentId];
            items[currentIndex] = currentItem;
            currentIndex += 1;
        }
        }
        return items;
    }

    /* Returns all unsold auction items */
    function fetchAuctionItems() public view returns (MarketItem[] memory) {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].owner == address(this) && idToMarketItem[i + 1].isAuction && (!influencer_featured[idToMarketItem[i + 1].creator] || idToMarketItem[i + 1].nonce != 0)) {
            itemCount += 1;
        }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].owner == address(this) && idToMarketItem[i + 1].isAuction && (!influencer_featured[idToMarketItem[i + 1].creator] || idToMarketItem[i + 1].nonce != 0)) {
            uint currentId = i + 1;
            MarketItem storage currentItem = idToMarketItem[currentId];
            items[currentIndex] = currentItem;
            currentIndex += 1;
        }
        }
        return items;
    }

    /* Returns only items that a user has purchased */
    function fetchUserNFTs(address user) public view returns (MarketItem[] memory) {
      uint totalItemCount = _tokenIds.current();
      uint itemCount = 0;
      uint currentIndex = 0;

      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].owner == user) {
          itemCount += 1;
        }
      }

      MarketItem[] memory items = new MarketItem[](itemCount);
      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].owner == user) {
          uint currentId = i + 1;
          MarketItem storage currentItem = idToMarketItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }

    /* Returns only items that a user has purchased */
    function fetchMyMarketNFTs(address user) public view returns (MarketItem[] memory) {
      uint totalItemCount = _tokenIds.current();
      uint itemCount = 0;
      uint currentIndex = 0;

      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].seller == user && idToMarketItem[i + 1].isMarket) {
          itemCount += 1;
        }
      }

      MarketItem[] memory items = new MarketItem[](itemCount);
      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].seller == user && idToMarketItem[i + 1].isMarket) {
          uint currentId = i + 1;
          MarketItem storage currentItem = idToMarketItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }

    function fetchMyAuctionNFTs(address user) public view returns (MarketItem[] memory) {
      uint totalItemCount = _tokenIds.current();
      uint itemCount = 0;
      uint currentIndex = 0;

      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].seller == user && idToMarketItem[i + 1].isAuction) {
          itemCount += 1;
        }
      }

      MarketItem[] memory items = new MarketItem[](itemCount);
      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].seller == user && idToMarketItem[i + 1].isAuction) {
          uint currentId = i + 1;
          MarketItem storage currentItem = idToMarketItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }

    function fetchItemsByFeatureInfluencers() public view returns (MarketItem[] memory) {
      uint totalItemCount = _tokenIds.current();
      uint itemCount = 0;
      uint currentIndex = 0;

      for (uint i = 0; i < totalItemCount; i++) {
          //is featured and on market or auction and first sale
        if (influencer_featured[idToMarketItem[i + 1].creator] && (idToMarketItem[i + 1].isAuction || idToMarketItem[i + 1].isMarket) 
        && idToMarketItem[i + 1].nonce == 0) {
          itemCount += 1;
        }
      }

      MarketItem[] memory items = new MarketItem[](itemCount);
      for (uint i = 0; i < totalItemCount; i++) {
        if (influencer_featured[idToMarketItem[i + 1].creator] && (idToMarketItem[i + 1].isAuction || idToMarketItem[i + 1].isMarket)
        && idToMarketItem[i + 1].nonce == 0) {
          uint currentId = i + 1;
          MarketItem storage currentItem = idToMarketItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;  
    }

    function fetchByTokenIds(uint256 [] calldata tokenIds) public view returns(string [] memory){
        string[] memory items = new string[](tokenIds.length);
        for(uint i =0; i < tokenIds.length; i ++)
        {
            uint256 tokenId = tokenIds[i];            
            items[i] = uri(tokenId);            
        }
        return items;
    }

    function fetchRarityByTokenIds(uint256 [] calldata tokenIds) public view returns(uint256 [] memory){
        uint256[] memory items = new uint256[](tokenIds.length);
        for(uint i =0; i < tokenIds.length; i ++)
        {            
            items[i] = idToMarketItem[tokenIds[i]].rarity;
        }
        return items;
    }
//abi.encodePacked("https://test.com/",Strings.toString(tier),"json");
    
}