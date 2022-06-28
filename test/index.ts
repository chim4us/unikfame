import { expect } from "chai";
import { ethers } from "hardhat";
export const royaltyAddr = "0xcd3b766ccdd6ae721141f452c550ca635964ce71"

describe("Greeter", function () {
  let addr1 : any, addr2: any, addr3: any,addr4 : any,addr5: any;
  let NFTMarketplace : any,nftmarketplace: any;
  let NFTMarketplaceErc1155 : any, nftmarketplaceerc1155 : any;
  var conBal : number = 0;

  it('Deployment ', async function()  {
    [addr1, addr2, addr3, addr4, addr5] = await ethers.getSigners();

    NFTMarketplaceErc1155 = await ethers.getContractFactory('NFTMarketplaceErc115');

    nftmarketplaceerc1155 = await NFTMarketplaceErc1155.deploy();
    await nftmarketplaceerc1155.deployed();
        
  });

  describe('Success Test',async () => {
    it('Should mint 100 tier 0 NFTs and list on marketPlace', async function()  {
      
      await nftmarketplaceerc1155.connect(addr1).createToken("Frank","test.com",10,0,100,royaltyAddr,100);

      const tknBal1 = parseInt(await nftmarketplaceerc1155.balanceOf(nftmarketplaceerc1155.address,0));
      conBal += 100;
      expect(tknBal1).to.equal(conBal);
    });

    it('Should fail when owner trys to mint 1000 tier one NFT', async function()  {
      await expect( nftmarketplaceerc1155.connect(addr1).createToken("Frank","test.com",10,0,1000,royaltyAddr,100)).to.be.revertedWith('No avalaible tier 0 NFT to be MINTED');
    });

    it('Should mint 100 tier 1 NFTs and list on marketPlace', async function()  {
      
      await nftmarketplaceerc1155.connect(addr1).createToken("Frank","test.com",10,1,100,royaltyAddr,100);

      const tknBal1 = parseInt(await nftmarketplaceerc1155.balanceOf(nftmarketplaceerc1155.address,1));
      conBal += 100;
      expect(tknBal1).to.equal(100);
    });

    it('Should mint 10 tier 3 NFTs and list on auction', async function()  {
      
      await nftmarketplaceerc1155.connect(addr1).createToken("Frank","test.com",10,3,10,royaltyAddr,10);

      const tknBal1 = parseInt(await nftmarketplaceerc1155.balanceOf(nftmarketplaceerc1155.address,3));
      conBal += 100;
      expect(tknBal1).to.equal(10);
    });

    it('Should mint 1 tier 4 NFTs and list on auction', async function()  {
      
      await nftmarketplaceerc1155.connect(addr1).createToken("Frank","test.com",10,4,1,royaltyAddr,10);

      const tknBal1 = parseInt(await nftmarketplaceerc1155.balanceOf(nftmarketplaceerc1155.address,4));
      conBal += 100;
      expect(tknBal1).to.equal(1);
    });

    it('Should make offer for tier 3 on auction', async function()  {
      
      await nftmarketplaceerc1155.connect(addr2).setOffer(11,3,5);

      let result = await nftmarketplaceerc1155.getOffer(3);
      const {0: biderValue, 1: priceValue, 2: quantityValue} = result;
      
    });

    it('Should make offer for tier 3 on auction', async function()  {
      
      await nftmarketplaceerc1155.connect(addr3).setOffer(12,3,5);

      let result = await nftmarketplaceerc1155.getOffer(3);
      const {0: biderValue, 1: priceValue, 2: quantityValue} = result;
      
    });
    
    it('Should make offer for tier 4 on auction', async function()  {
      
      await nftmarketplaceerc1155.connect(addr4).setOffer(12,4,1);

      let result = await nftmarketplaceerc1155.getOffer(4);
      const {0: biderValue, 1: priceValue, 2: quantityValue} = result;

      console.log("Bider Address: ",biderValue[0]);
      console.log("price : ",parseInt(priceValue[0]));
      console.log("quantity : ",parseInt(quantityValue[0]));
      
    });

    it('Should make offer for tier 4 on auction', async function()  {
      
      await nftmarketplaceerc1155.connect(addr5).setOffer(200,4,1);

      let result = await nftmarketplaceerc1155.getOffer(4);
      const {0: biderValue, 1: priceValue, 2: quantityValue} = result;

      console.log("Bider Address: ",biderValue[1]);
      console.log("price : ",parseInt(priceValue[1]));
      console.log("quantity : ",parseInt(quantityValue[1]));
      
    });

  });


  // describe('Success Test',async () => {
  //   it('Should mint 100 NFTs and list on marketPlace', async function()  {
      
  //     await nftmarketplaceerc1155.connect(addr1).createToken("Frank","test.com",10,0,0,100,royaltyAddr,1203202);
  //     const tknBal = await nftmarketplaceerc1155.balanceOf(addr1.address,0);

  //     const tknBal1 = parseInt(await nftmarketplaceerc1155.balanceOf(nftmarketplaceerc1155.address,0));
  //     conBal += 100;
  //     expect(tknBal1).to.equal(conBal);
  //   });

  //   it('Should mint 100 NFTs and list on marketPlace', async function()  {
      
  //     await nftmarketplaceerc1155.connect(addr1).createToken("Frank","test.com",10,0,0,100,royaltyAddr,1203202);
  //     const tknBal = await nftmarketplaceerc1155.balanceOf(addr1.address,0);

  //     const tknBal1 = parseInt(await nftmarketplaceerc1155.balanceOf(nftmarketplaceerc1155.address,0));
  //     conBal += 100;
  //     expect(tknBal1).to.equal(conBal);
  //   });

  //   it('Should mint 100 NFTs and list on marketPlace', async function()  {
      
  //     await nftmarketplaceerc1155.connect(addr1).createToken("Frank","test.com",10,0,0,100,royaltyAddr,1203202);
  //     const tknBal = await nftmarketplaceerc1155.balanceOf(addr1.address,0);

  //     const tknBal1 = parseInt(await nftmarketplaceerc1155.balanceOf(nftmarketplaceerc1155.address,0));
  //     conBal += 100;
  //     expect(tknBal1).to.equal(conBal);
  //   });

  //   it('Should resellToken 100 NFTs tokens', async function()  {
      
  //     await nftmarketplaceerc1155.connect(addr1).resellToken(0,10,100);
  //     const tknBal = await nftmarketplaceerc1155.balanceOf(addr1.address,0);

  //     const tknBal1 = parseInt(await nftmarketplaceerc1155.balanceOf(nftmarketplaceerc1155.address,0));
  //     conBal += 100;
  //     expect(tknBal1).to.equal(conBal);
  //   });

  // });
});