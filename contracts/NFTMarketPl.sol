// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";


pragma solidity ^0.8.4;

interface Tkn{
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ERC1155TokenReceiver {
    
    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns(bytes4);

    
    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns(bytes4);       
}


contract NFTMarketplaceErc115 is ERC1155URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _userIds;
    Counters.Counter private _influencerIds;
    address payable owner;
    address payable usdtAdr;
    uint256 listingPrice = 0.025 ether;
    uint256 numberOfFreeMembership = 500;
    uint[] public uniknums = [1000,500,100,10,1];
    
    address payable Unikfame = payable(0xFE2AF94b186868D417c4b2608D650e0f3857af94); // 60%
    address payable Wesley = payable(0xe94061b6Ba385D5352801Ab077BfBAf9E194AA36); // 2.5%
    address payable Gaetan = payable(0xaD993C0E3043EC94aFe91e68fAd3cb7aB50f0a1F); // 2.5%
    address payable Sam = payable(0x394Ab6172dE75359cdB145E231Efb23a4f17e258); // 8%
    address payable Mike = payable(0xFE8201Ce69A82DEa64e633eC37b0b719eD316402); // 1%
    address payable Dev = payable(0x9963257171Fba4627fCb94a4423ebB03a27644ED); // 1%

    struct NFTItemMarketPlc {
        uint256 tokenId;
        uint256 creatTm;
        uint256 quantity;
        address payable owner;
        address payable royalty;
        uint256 price;
        string tokenURI;
        uint256 Tier;
        bool status;
    }

    struct NFTItemAuction {
        uint256 tokenId;
        uint256 creatTm;
        uint256 ActEndTm;
        uint256 quantity;
        uint256 bidStPrc;
        address payable owner;
        address payable royalty;
        string tokenURI;
        uint256 Tier;
        bool status;
    }

    struct Offer{
        uint256 price;
        address payable Bider;
        uint256 timestamp;
        uint256 quantity;
    }

    mapping(uint256 => NFTItemMarketPlc) private idToNFTMrkItem;
    mapping(uint256 => Offer) private idToOffers;
    mapping (uint256 => uint256) tokenIdToOfferId;
    mapping(uint256 => NFTItemAuction) private idToNFTActItem;
    mapping(address => NFTItemAuction) private addrToNFTActItem;
    mapping (string => bool) public influencer_exist;
    mapping (uint256 => string) public influencer_str;
    mapping (string => bool) public influencer_featured;
    mapping (uint256 => uint256) public MintedNFTTier;
    mapping (uint256 => Offer[]) public offers;
    string private _creator;

    event MarketItemTx (
        uint tokenId,
        address seller,
        address owner,
        uint256 price,
        uint256 timestamp,
        uint256 quantity
    );

    event AuctionItemBid (
        uint256 tokenId,
        address seller,
        address owner,
        uint256 stPrice,
        uint256 timestamp,
        uint256 quantity,
        uint256 AuctEndTm
    );

    event AuctionTrx(
        address Bider, 
        uint256 tokenId,
        uint256 quantity
    );


    constructor(address _usdtAdr) ERC1155("test.com") {
      owner = payable(msg.sender);
      usdtAdr = payable(_usdtAdr);
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
        influencer_featured[_influencer] = true;
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

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function createToken(string memory creator, string memory tokenURI, uint256 price, uint256 tier, uint256 Nftnum, address royalty, uint256 _ActEndTm) public returns (uint256){
        require(msg.sender == owner, "Only Owner Can Mint");
        require(tier == 0||tier == 1||tier == 2||tier == 3||tier == 4, "Tier can only be between 0 ~ 4");
        addinfluencer(creator); // add influencer name to the list
        _creator = creator;

        (bool Tr, uint256 Result) = tryAdd(MintedNFTTier[tier],Nftnum);

        require(Tr, "No avalaible tier 0 NFT to be MINTED");

        if(tier == 0){
            require(Result <= uniknums[0], "No avalaible tier 0 NFT to be MINTED");
        }else if(tier == 1){
            require(Result <= uniknums[1], "No avalaible tier 1 NFT to be MINTED");
        }else if(tier == 2){
            require(Result <= uniknums[2], "No avalaible tier 2 NFT to be MINTED");
        }else if(tier == 3){
            require(Result <= uniknums[3], "No avalaible tier 3 NFT to be MINTED");
        }else if(tier == 4){
            require(Result <= uniknums[4], "No avalaible tier 4 NFT to be MINTED");
        }

        _mint(msg.sender,tier,Nftnum,"");

        _setURI(tier, tokenURI);

        if((tier == 0) || (tier == 1) || (tier == 2)){
            createMarketItem(
            tier, Nftnum, royalty, price,
            tokenURI, tier
            );
        }else if((tier == 3) || (tier == 4)) {
            //Auction
            createAuctionItem(
                tier, _ActEndTm, Nftnum,
                royalty,tokenURI,tier, price
            );
        }
        MintedNFTTier[tier] += Nftnum;
        
    }

    function tryAdd(uint256 a, uint256 b) private pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }


    function createMarketItem(
        uint256 _tokenId,uint256 _quantity,address _royalty,uint256 _price,
        string memory _tokenURI,uint256 _Tier
    )private {
        
        idToNFTMrkItem[_tokenId] =  NFTItemMarketPlc(
            _tokenId,
            block.timestamp,
            _quantity,
            payable(msg.sender),
            payable(_royalty),
            _price,
            _tokenURI,
            _Tier,
            true
        );

        _safeTransferFrom(msg.sender,address(this),_tokenId,_quantity,"");
        
        emit MarketItemTx (
        _tokenId,
        address(this),
        msg.sender,
        _price,
        block.timestamp,
        _quantity
        );

    }

    function createAuctionItem(
        uint256 _tokenId,uint256 _ActEndTm,uint256 _quantity,
        address _royalty,string memory _tokenURI,uint256 _Tier,uint256 _bidStPrc
    )private {
        require(_bidStPrc > 0, "Bid start price must be greater than zero");

        addrToNFTActItem[msg.sender] =  NFTItemAuction(
            _tokenId,
            block.timestamp,
            block.timestamp + _ActEndTm,
            _quantity,
            _bidStPrc,
            payable(msg.sender),
            payable(_royalty),
            _tokenURI,
            _Tier,
            true
        );

        idToNFTActItem[_tokenId] =  NFTItemAuction(
            _tokenId,
            block.timestamp,
            block.timestamp + _ActEndTm,
            _quantity,
            _bidStPrc,
            payable(msg.sender),
            payable(_royalty),
            _tokenURI,
            _Tier,
            true
        );

        _safeTransferFrom(msg.sender,address(this),_tokenId,_quantity,"");

        emit AuctionItemBid (
            _tokenId,
            address(this),
            msg.sender,
            _bidStPrc,
            block.timestamp,
            _quantity,
            block.timestamp + _ActEndTm
        );

    }

    function setOffer(address _nftOwner, uint256 _price, uint256 _tokenId,uint256 _quantity) public{
        Tkn Token = Tkn(usdtAdr);
        require(addrToNFTActItem[_nftOwner].status == false && addrToNFTActItem[_nftOwner].quantity > 0,"NFT not on Auction");
        //require(idToOffers[_tokenId].price == 0, "You can't sell twice the same offers ");
        //require(_tokenId == 3 || _tokenId == 4, "Offer can only be done on Platinum and Diamond NFT's");
        require(Token.allowance(msg.sender,address(this)) > _price,"Please approve USDT above the price amount");
        require(addrToNFTActItem[_nftOwner].quantity >= _quantity, "Not Enough NFT on auction");
        require(block.timestamp <= addrToNFTActItem[_nftOwner].ActEndTm,"Action ended");
        require(_price >= addrToNFTActItem[_nftOwner].bidStPrc,"Bid amount can only be greater than the starting auction price");

        Offer memory _offer = Offer({
            price: _price,
            Bider: payable(msg.sender),
            timestamp: block.timestamp,
            quantity: _quantity
        });

        idToOffers[_tokenId] = _offer;

        offers[_tokenId].push(_offer);

        uint256 index = offers[_tokenId].length - 1;

        tokenIdToOfferId[_tokenId] = index;

        emit AuctionTrx( msg.sender, _tokenId,_quantity);
    }

    function getActionOffers(uint256 _tokenId)public view returns(address[] memory bider,uint256[] memory price,uint256[] memory quantity) {
        //Offer storage offer = idToOffers[_tokenId];
        uint256 totalOffers = offers[_tokenId].length;
        address[] memory adr = new address[](1);
        address[] memory resultAddress = new address[](totalOffers);
        uint256[] memory _price = new uint256[](totalOffers);
        uint256[] memory _quantity = new uint256[](totalOffers);

        adr[0] = address(0);
        //adr.push(address(0));
        if (totalOffers == 0) {
            return (adr,new uint256[](0),new uint256[](0));
        } else {
            for (uint256 offerId = 0; offerId < offers[_tokenId].length; offerId++) {
                if(offers[_tokenId][offerId].price != 0){
                    resultAddress[offerId] = offers[_tokenId][offerId].Bider;
                    _price[offerId] = offers[_tokenId][offerId].price;
                    _quantity[offerId] = offers[_tokenId][offerId].quantity;
                }
            }
            return (resultAddress,_price,_quantity);
        }
    }

    function endAuction(uint256 _tokenId) public payable {
        require(idToNFTActItem[_tokenId].owner == msg.sender,"You cannot end this auction NFT");
        require(idToNFTActItem[_tokenId].status,"You cannot end this auction NFT");
        require(block.timestamp >= idToNFTActItem[_tokenId].ActEndTm ,"Auction not ended yet");

        (address[] memory _bider,uint256[] memory _price,uint256[] memory _quantity) = getActionOffers(_tokenId);
        Tkn Token = Tkn(usdtAdr);

        if((_bider.length == 0) && (_bider[0] == address(0))){
            _safeTransferFrom(address(this),msg.sender,_tokenId,idToNFTActItem[_tokenId].quantity,"");
        }else{
            uint256 price;
            uint256 _quan;
            address bider;
            for(uint256 offerId = 0; offerId < _bider.length; offerId++){
                if((_price[offerId] > price)&&(Token.balanceOf(_bider[offerId]) >= _price[offerId])){
                    bider = _bider[offerId];
                    _quan = _quantity[offerId];
                    price = _price[offerId];
                    
                }
            }

            send_funds3(price, idToNFTActItem[_tokenId].royalty, idToNFTActItem[_tokenId].owner,bider);
            _safeTransferFrom(address(this),msg.sender,_tokenId,_quan,"");
        }
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
    function send_funds3(uint256 price, address royalty, address seller,address _bider) internal {
        Tkn Token = Tkn(usdtAdr);
        Token.transferFrom(_bider,seller,(price*80/100));
        Token.transferFrom(_bider,royalty,(price*5/100));
        Token.transferFrom(_bider,Unikfame,(price*15/100));
        
        // payable(seller).transfer(price*80/100);  
        // payable(royalty).transfer(price*5/100);
        // payable(Unikfame).transfer(price*15/100);
    }

    function fetchMyAuctionNFTs(address user) public view returns (NFTItemAuction[] memory) {

    }

}