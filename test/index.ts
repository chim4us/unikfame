import { expect } from "chai";
import { ethers } from "hardhat";
export const royaltyAddr = "0xcd3b766ccdd6ae721141f452c550ca635964ce71"

describe("Greeter", function () {
  let addr1 : any, addr2, addr3,addr4,addr5;
  let NFTMarketplace : any,nftmarketplace: any;
  let NFTMarketplaceErc1155 : any, nftmarketplaceerc1155 : any;
  var conBal : number = 0;

  it('Deployment ', async function()  {
    [addr1, addr2, addr3, addr4, addr5] = await ethers.getSigners();

    NFTMarketplaceErc1155 = await ethers.getContractFactory('NFTMarketplaceErc1155');

    nftmarketplaceerc1155 = await NFTMarketplaceErc1155.deploy();
    await nftmarketplaceerc1155.deployed();
        
  });

  describe('Success Test',async () => {
    it('Should mint 100 NFTs and list on marketPlace', async function()  {
      
      await nftmarketplaceerc1155.connect(addr1).createToken("Frank","test.com",10,0,1,100,royaltyAddr,1203202);
      const tknBal = await nftmarketplaceerc1155.balanceOf(addr1.address,0);

      const tknBal1 = parseInt(await nftmarketplaceerc1155.balanceOf(nftmarketplaceerc1155.address,0));
      conBal += 100;
      expect(tknBal1).to.equal(conBal);
    });

    it('Should mint 100 NFTs and list on marketPlace', async function()  {
      
      await nftmarketplaceerc1155.connect(addr1).createToken("Frank","test.com",10,0,0,100,royaltyAddr,1203202);
      const tknBal = await nftmarketplaceerc1155.balanceOf(addr1.address,0);

      const tknBal1 = parseInt(await nftmarketplaceerc1155.balanceOf(nftmarketplaceerc1155.address,0));
      conBal += 100;
      expect(tknBal1).to.equal(conBal);
    });

    it('Should mint 100 NFTs and list on marketPlace', async function()  {
      
      await nftmarketplaceerc1155.connect(addr1).createToken("Frank","test.com",10,0,0,100,royaltyAddr,1203202);
      const tknBal = await nftmarketplaceerc1155.balanceOf(addr1.address,0);

      const tknBal1 = parseInt(await nftmarketplaceerc1155.balanceOf(nftmarketplaceerc1155.address,0));
      conBal += 100;
      expect(tknBal1).to.equal(conBal);
    });

    it('Should resellToken 100 NFTs tokens', async function()  {
      
      await nftmarketplaceerc1155.connect(addr1).resellToken(0,10,100);
      const tknBal = await nftmarketplaceerc1155.balanceOf(addr1.address,0);

      const tknBal1 = parseInt(await nftmarketplaceerc1155.balanceOf(nftmarketplaceerc1155.address,0));
      conBal += 100;
      expect(tknBal1).to.equal(conBal);
    });

  });
});