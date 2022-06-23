import React, { useState } from 'react';
import PropTypes from 'prop-types'
import { Link } from 'react-router-dom'
import CardModal from '../CardModal'
import Countdown from "react-countdown";
import { useNavigate } from 'react-router-dom';
import unikfamelogo from '../../../assets/images/logo/nft-logo.png';
import { useContext } from 'react';
import { LoginContext } from '../../../context/LoginContext';

const LiveAuction = props => {
    const { changeAccount, signer, mprice } = useContext(LoginContext);
    const data = props.data;
    const [modalShow, setModalShow] = useState(false);
    const [cprice, setCprice] = useState(0);
    const [count, setCount] = useState(0);
    const [c_tokenId, set_tokenId] = useState([]);
    const [visible, setVisible] = useState(8);
    const [tmarkettype, setmarkettype] = useState();
    const navigate = useNavigate();
    const getDetail = (item) => {
        console.log(item);
        navigate("/item-details-01", { state: { ...item, markettype: item.timestamp == 0 ? 0 : 1 } })
    }
    const showMoreItems = () => {
        setVisible((prevValue) => prevValue + 4);
    }

    return (

        <section className="tf-section live-auctions">
            <div className="themesflat-container">
                <div className="row">
                    {
                        data.slice(0, visible).map((item, index) => (
                            <div className="fl-item col-xl-3 col-lg-6 col-md-6">
                                <div className="sc-card-product">
                                    <div className="card-media">
                                        <div onClick={() => { getDetail(item); }}><img src={item.img} alt="axies" /></div>
                                        <div /*to="/login" */ className="wishlist-button"><span className="number-like">{item.point}</span></div>
                                        {
                                            item.timestamp != 0 && (<div className="featured-countdown">
                                                <div>
                                                    <img className="logo-auction-icon" src={unikfamelogo}></img>
                                                </div>
                                                <Countdown date={item.timestamp * 1000}>
                                                    <span>CLOSED!!!</span>
                                                </Countdown>
                                            </div>)
                                        }
                                        <div className="button-place-bid">
                                            <button onClick={() => {
                                                if (!signer) {
                                                    changeAccount();
                                                    return;
                                                }
                                                setCount(item.count);
                                                set_tokenId(item.tokenIds);
                                                setCprice(item.price);
                                                setmarkettype(item.timestamp == 0 ? 0 : 1);
                                                setModalShow(true);
                                            }} className="sc-button style-place-bid style bag fl-button pri-3"><span>{item.timestamp == 0 ? "Buy now" : "Bid now"}</span></button>
                                        </div>
                                    </div>
                                    <div className="card-title">
                                        <h5><Link to="#">{item.title}({item.count})</Link></h5>
                                        <div className="tags">{item.tier}</div>
                                    </div>
                                    <div className="meta-info">
                                        <div className="price">
                                            <span>{item.timestamp == 0 ? "Price" : "Current Bid"}</span>
                                        </div>
                                    </div>
                                    <div className="meta-info">
                                        <div className="price">
                                            <p> ${(item.price * mprice).toFixed(2)}</p>
                                        </div>
                                        <div className="price">
                                            <p> {item.price} MATIC</p>
                                        </div>
                                    </div>
                                    <div className="author">
                                        <div className="info detail-button" onClick={() => { getDetail(item); }}>
                                            <h6>View Details</h6>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        ))
                    }
                    {
                        visible < data.length &&
                        <div className="col-md-12 wrap-inner load-more text-center">
                            <Link to="#" id="load-more" className="sc-button loadmore fl-button pri-3" onClick={showMoreItems}><span>Load More</span></Link>
                        </div>
                    }
                </div>
            </div>
            <CardModal
                _currentprice={cprice}
                tokenIds={c_tokenId}
                maxcount={count}
                market_type={tmarkettype}
                show={modalShow}
                onHide={() => setModalShow(false)}
            />
        </section>
    );
}

LiveAuction.propTypes = {
    data: PropTypes.array.isRequired,
}



export default LiveAuction;
