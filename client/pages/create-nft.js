import { useState, useEffect } from "react";
import { ethers } from "ethers";
import { create as ipfsHttpClient } from "ipfs-http-client";
import { useRouter } from "next/router";
import Web3Modal from "web3modal";
import axios from "axios";

//const client = ipfsHttpClient('https://ipfs.infura.io:5001/api/v0')
//const client = ipfsHttpClient('https://gateway.pinata.cloud/ipfs/')

//WTF? Remove keys from this place

const pinataApiKey = "48dff178bbcf55a894a8";
const pinataSecretApiKey =
  "c91ae96ee962a543127a8b459e4ee985ad0741751d048bf88ba11b60f8047851";

const gateway_url = "https://unikfame.mypinata.cloud/ipfs/";

import { marketplaceAddress } from "../../config";

import NFTMarketplace from "../../artifacts/contracts/NFTMarketplace.sol/NFTMarketplace.json";

export default function CreateItem() {
  const [selectedTier, setSelectedTier] = useState(0);
  const [selectedCategory, setSelectedCategory] = useState(0);
  const [fileUrl, setFileUrl] = useState("");
  const [formInput, updateFormInput] = useState({
    royalty: "0x9963257171Fba4627fCb94a4423ebB03a27644ED",
    price: "",
    name: "",
    description: "",
    type: 0,
    influencer: "",
    count: 0,
  });
  const [url, setUrl] = useState("");
  const rarityData = ["Bronze", "Silver", "Gold", "Platinum", "Diamond"];
  const categoryData = [
    "Beauty",
    "Health",
    "Fitness",
    "Sports",
    "Entertainment",
    "Family",
    "Fashion",
    "Business",
    "Lifestyle",
    "Music",
    "Food",
  ];

  useEffect(() => {
    setUrl("");
  }, []);

  const handleOptionChange = (e) => {
    console.log(e.target.value);
    setSelectedTier(e.target.value);
  };
  const handleCatOptionChange = (e) => {
    console.log(e.target.value);
    setSelectedCategory(e.target.value);
  };

  async function onChange(e) {
    const file = e.target.files[0];
    try {
      let data = new FormData();
      data.append("file", file);
      const url = `https://api.pinata.cloud/pinning/pinFileToIPFS`;
      const res = await axios.post(url, data, {
        maxBodyLength: "Infinity", //this is needed to prevent axios from erroring out with large files
        headers: {
          "Content-Type": `multipart/form-data; boundary=${data._boundary}`,
          pinata_api_key: pinataApiKey,
          pinata_secret_api_key: pinataSecretApiKey,
        },
      });
      console.log(res);
      setFileUrl(gateway_url + res.data.IpfsHash);
    } catch (error) {
      console.log("Error uploading file: ", error);
    }
  }

  async function listNFTForSale() {
    console.log(url);
    const { count, royalty, influencer, type } = formInput;
    // const web3Modal = new Web3Modal()
    // const connection = await web3Modal.connect()
    const provider = new ethers.providers.Web3Provider(window.ethereum, "any");
    await provider.send("eth_requestAccounts", []);
    const signer = provider.getSigner();

    /* next, create the item */
    const price = ethers.utils.parseUnits(formInput.price, "ether");
    let contract = new ethers.Contract(
      marketplaceAddress,
      NFTMarketplace.abi,
      signer
    );

    let transaction = await contract.createToken(
      influencer,
      url,
      price,
      type,
      selectedTier,
      count,
      royalty,
      180
    );
    await transaction.wait();
    window.location.reload();
  }

  async function uploadIPFS() {
    const { name, description, price, influencer } = formInput;

    const rarity_point = [10, 100, 1000, 5000, 10000];
    if (!name || !description || !price || !fileUrl) return;
    /* first, upload to IPFS */
    const data = {
      name,
      description,
      image: fileUrl,
      external_url: "",
      attributes: [
        {
          trait_type: "Rarity",
          value: rarityData[selectedTier],
        },
        {
          trait_type: "Category",
          value: categoryData[selectedCategory],
        },
        {
          trait_type: "Influencer",
          value: influencer,
        },
        {
          trait_type: "Point",
          value: rarity_point[selectedTier],
        },
      ],
    };
    console.log(data);

    try {
      const url = `https://api.pinata.cloud/pinning/pinJSONToIPFS`;
      const response = await axios.post(url, data, {
        headers: {
          pinata_api_key: pinataApiKey,
          pinata_secret_api_key: pinataSecretApiKey,
        },
      });
      setUrl(gateway_url + response.data.IpfsHash);
      console.log(response);
      return gateway_url + response.data.IpfsHash;
    } catch (error) {
      console.log("Error uploading json: ", error);
    }
  }

  return (
    <div className="flex justify-center">
      <div className="w-1/2 flex flex-col pb-12">
        <input
          placeholder="Asset Name"
          className="mt-8 border rounded p-4"
          onChange={(e) =>
            updateFormInput({ ...formInput, name: e.target.value })
          }
        />
        <textarea
          placeholder="Asset Description"
          className="mt-2 border rounded p-4"
          onChange={(e) =>
            updateFormInput({ ...formInput, description: e.target.value })
          }
        />
        <div className="flex justify-around">
          {rarityData.map((rarity, index) => {
            return (
              <div key={index} className="radio">
                <label>
                  <input
                    type="radio"
                    value={index}
                    checked={selectedTier == index}
                    onChange={handleOptionChange}
                  />
                  {rarity}
                </label>
              </div>
            );
          })}
        </div>
        <div className="flex justify-around">
          {categoryData.map((category, index) => {
            return (
              <div key={index} className="radio">
                <label>
                  <input
                    type="radio"
                    value={index}
                    checked={selectedCategory == index}
                    onChange={handleCatOptionChange}
                  />
                  {category}
                </label>
              </div>
            );
          })}
        </div>
        <input
          placeholder="Influencer"
          className="mt-2 border rounded p-4"
          onChange={(e) =>
            updateFormInput({ ...formInput, influencer: e.target.value })
          }
        />
        <input
          placeholder="Royalty"
          className="mt-2 border rounded p-4"
          value={formInput.royalty}
          onChange={(e) =>
            updateFormInput({ ...formInput, royalty: e.target.value })
          }
        />
        <div className="flex">
          <input
            type="file"
            name="Asset"
            className="my-4"
            onChange={onChange}
          />
          {fileUrl && <img className="rounded mt-4" width="50" src={fileUrl} />}
        </div>
        <input
          placeholder="fileUrl"
          className="mt-2 border rounded p-4"
          value={fileUrl}
          onChange={(e) => setFileUrl(e.target.value)}
        />
        <input
          placeholder="Asset Price in Eth"
          className="mt-2 border rounded p-4"
          onChange={(e) =>
            updateFormInput({ ...formInput, price: e.target.value })
          }
        />
        <div className="flex justify-around">
          <input
            placeholder="0 == Market 1== Auction"
            className="mt-2 border rounded p-4"
            onChange={(e) =>
              updateFormInput({ ...formInput, type: e.target.value })
            }
          />
          <input
            placeholder="Count"
            className="mt-2 border rounded p-4"
            onChange={(e) =>
              updateFormInput({ ...formInput, count: e.target.value })
            }
          />
        </div>

        <input
          placeholder="url"
          className="mt-2 border rounded p-4"
          value={url}
          onChange={(e) => setUrl(e.target.value)}
        />
        <button
          onClick={uploadIPFS}
          className="font-bold mt-4 bg-pink-500 text-white rounded p-4 shadow-lg"
        >
          Upload IPFS
        </button>
        <button
          onClick={listNFTForSale}
          className="font-bold mt-4 bg-pink-500 text-white rounded p-4 shadow-lg"
        >
          Create NFT
        </button>
      </div>
    </div>
  );
}
