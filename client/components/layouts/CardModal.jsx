import React from 'react';
import { Modal } from "react-bootstrap";
import { useEffect, useState, useContext } from 'react';
import Web3Modal from 'web3modal'
import { ethers } from 'ethers'
import { Venly } from '@venly/web3-provider';
import { RampInstantSDK } from '@ramp-network/ramp-instant-sdk';
import unikfamelogo from '../../assets/images/logo/nft-logo.png'

import { LoginContext } from '../../context/LoginContext';

import NFTMarketplace from '../../abi/NFTMarketplace.json'
import marketplaceAddress from '../../config';

const CardModal = (props) => {
    const { userCard, balance, signer, mprice, account } = useContext(LoginContext);
    const [currentprice, setCurrentprice] = useState(0);
    const [num, setNum] = useState(1);
    const tokenIds = props.tokenIds;
    const cprice = props._currentprice;
    const maxcount = props.maxcount;
    const market_type = props.market_type;
    const buttonText = ["Buy Now", "Place a Bid", "Sell Now", "Cancel Now"];
    const headerText = ["Price ", "Minimum Bid", "Price ", "Price "];
    const priceText = ["Total Price", "Total bid amount", "Total Price", "Total Price"];
    useEffect(() => {
        setCurrentprice(cprice);
    }, [cprice])
    const handleBidorBuy = async () => {
        const marketplaceContract = new ethers.Contract(marketplaceAddress, NFTMarketplace.abi, signer)
        let arr_Ids = tokenIds.slice(0, num).map(i => Number(i._hex));
        let price = ethers.utils.parseUnits((Number(num) * Number(currentprice)).toString(), 'ether')

        if (market_type === 0) {
            await marketplaceContract.createMarketSale(arr_Ids, {
                value: price
            });
        }
        else if (market_type === 1) {
            await marketplaceContract.createAuctionSale(arr_Ids, {
                value: price
            });
        }
        else if (market_type === 2) {
            await marketplaceContract.resellToken(arr_Ids, price);
        }
        else if (market_type === 3) {
            await marketplaceContract.cancelToken(arr_Ids);
        }
        props.onHide();
    }
    const managewallet = async () => {
        new RampInstantSDK({
            hostAppName: 'UnikFame',
            hostLogoUrl: unikfamelogo,
            userAddress: account,
            defaultAsset: 'MATIC_MATIC'
        }).show();
    }
    return (

        <Modal
            show={props.show}
            onHide={props.onHide}
        >
            <Modal.Header closeButton></Modal.Header>

            <div key={props._currentprice} className="modal-body space-y-20 pd-40">
                {/* <h3>{headerText[market_type]}</h3>
                {!userCard.isWhitelist && <p className="text-center">Must purchase user card</p>} */}
                <p className="text-center">{headerText[market_type]} <span className="price color-popup">${(cprice * mprice).toFixed(2)} ({cprice} MATIC) </span>
                </p>
                <input type="text" className="form-control" value={currentprice} disabled={market_type === 0} onChange={(e) => setCurrentprice(e.target.value)}
                    placeholder="00.00 MATIC" />
                <p>Enter quantity. <span className="color-popup">{maxcount} available</span>
                </p>
                <input max={maxcount} min={1} type="number" value={num} onChange={e => setNum(e.target.value)} className="form-control" placeholder="1" />
                <div className="hr"></div>
                {/* <div className="d-flex justify-content-between">
            <p> You must bid at least:</p>
            <p className="text-right price color-popup"> 4.89 ETH </p>
        </div> */}
                {/* <div className="d-flex justify-content-between">
            <p> Service free:</p>
            <p className="text-right price color-popup"> 0,89 ETH </p>
        </div> */}
                <div className="d-flex justify-content-between">
                    <p> {priceText[market_type]}:</p>
                    <p className="text-right price color-popup"> ${(Number(num) * Number(currentprice) * mprice).toFixed(2)} ({(Number(num) * Number(currentprice)).toFixed(2)} MATIC)</p>
                </div>
                {balance < (Number(num) * Number(currentprice)) ? (
                    <div className="d-flex justify-content-between align-items-center">
                        <p className='p-red'>Insufficient Funds</p>
                        <p className='p-red buy-matic' onClick={() => { managewallet(); }}>Buy MATIC</p>
                    </div>
                ) : ""}
                <button onClick={handleBidorBuy} className="btn btn-primary" >{buttonText[market_type]}</button>
            </div>
        </Modal>

    );
};

export default CardModal;
