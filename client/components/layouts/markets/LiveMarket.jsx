import React, { useState } from 'react';
import PropTypes from 'prop-types'
import { Link } from 'react-router-dom'
import CardModal from '../CardModal'
// import Countdown from "react-countdown";
import { useNavigate } from 'react-router-dom';


const LiveMarket = props => {
    const data = props.data;
    const [cprice, setCprice] = useState(0);
    const [modalShow, setModalShow] = useState(false);
    const [visible, setVisible] = useState(8);
    const [count, setCount] = useState(0);
    const [c_tokenId, set_tokenId] = useState([]);
    const navigate = useNavigate();
    const getDetail = (item) => {
        navigate("/item-details-01", { state: {...item,markettype:0} })
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
                                        <Link to="/login" className="wishlist-button"><span className="number-like">{item.point}</span></Link>
                                        {/* <div className="featured-countdown">
                                            <span className="slogan"></span>
                                            <Countdown date={Date.now() + 500000000}>
                                                <span>You are good to go!</span>
                                            </Countdown>
                                        </div> */}
                                        <div className="button-place-bid">
                                            <button onClick={() => {
                                                setModalShow(true);
                                                setCount(item.count);
                                                set_tokenId(item.tokenIds);
                                                setCprice(item.price)
                                            }} className="sc-button style-place-bid style bag fl-button pri-3"><span>Buy now</span></button>
                                        </div>
                                    </div>
                                    <div className="card-title">
                                        <h5><Link to="/item-details-01">{item.title}({item.count})</Link></h5>
                                        <div className="tags">{item.tier}</div>
                                    </div>
                                    <div className="meta-info">
                                        <div className="author">
                                            <div className="info">
                                                <span>Followers</span>
                                                <h6> <div >{item.followers}</div> </h6>
                                            </div>
                                        </div>
                                        <div className="price">
                                            <span>Current Price</span>
                                            <h5> {item.price} MATIC</h5>
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
                market_type={0}
                show={modalShow}
                onHide={() => setModalShow(false)}
            />
        </section>
    );
}

LiveMarket.propTypes = {
    data: PropTypes.array.isRequired,
}

export default LiveMarket;
