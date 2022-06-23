import React, { useState, Fragment } from 'react';
import PropTypes from 'prop-types'
import { Link } from 'react-router-dom'
import { Swiper, SwiperSlide } from 'swiper/react';
import { Navigation, Pagination, Scrollbar, A11y } from 'swiper';
import Countdown from "react-countdown";
import CardModal from './CardModal'
import { useNavigate } from 'react-router-dom';
import 'swiper/scss';
import 'swiper/scss/navigation';
import 'swiper/scss/pagination';

const LiveAuction = props => {
    const data = props.data;
    const market_type = props.market_type;
    const [cprice, setcprice] = useState();
    const [c_tokenId, set_tokenId] = useState([]);
    const [count, setCount] = useState(0);
    const [modalShow, setModalShow] = useState(false);
    const navigate = useNavigate();
    const getDetail = (item) => {
        navigate("/item-details-01", { state: item })
    }
    return (
        <Fragment>
            <section className="tf-section live-auctions">
                <div className="themesflat-container">
                    <div className="row">
                        <div className="col-md-12">
                            <Swiper
                                modules={[Navigation, Pagination, Scrollbar, A11y]}
                                spaceBetween={30}

                                breakpoints={{
                                    0: {
                                        slidesPerView: 1,
                                    },
                                    767: {
                                        slidesPerView: 2,
                                    },
                                    991: {
                                        slidesPerView: 3,
                                    },
                                    1300: {
                                        slidesPerView: 4,
                                    },
                                }}
                                navigation
                                pagination={{ clickable: true }}
                                scrollbar={{ draggable: true }}
                            >
                                {
                                    data.slice(0, 7).map((item, index) => (
                                        <SwiperSlide key={index}>
                                            <div className="swiper-container show-shadow carousel auctions">
                                                <div className="swiper-wrapper">
                                                    <div className="swiper-slide">
                                                        <div className="slider-item">
                                                            <div className="sc-card-product">
                                                                <div className="card-media">
                                                                    <div onClick={() => { getDetail(item); }}><img src={item.img} alt="axies" /></div>
                                                                    <Link to="/login" className="wishlist-button"><span className="number-like">{item.point}</span></Link>
                                                                    {/* <div className="featured-countdown">
                                                                        <span className="slogan"></span>
                                                                        <Countdown date={Date.now() + 5000}>
                                                                            <span>You are good to go!</span>
                                                                        </Countdown>
                                                                    </div> */}
                                                                    <div className="button-place-bid">
                                                                        <button onClick={() => {
                                                                            setModalShow(true);
                                                                            setCount(item.count);
                                                                            set_tokenId(item.tokenIds);
                                                                            setcprice(item.price);
                                                                            //console.log(item.price)
                                                                        }} className="sc-button style-place-bid style bag fl-button pri-3"><span>{market_type === 1 ? ('Place Bid') : ('Buy Nft')}</span></button>
                                                                    </div>
                                                                </div>
                                                                <div className="card-title">
                                                                    <h5><Link to="/item-details-01">{item.title}({item.count})</Link></h5>
                                                                    <div className="tags">{item.rarity}</div>
                                                                </div>
                                                                <div className="meta-info">
                                                                    <div className="author">
                                                                        <div className="info">
                                                                            <span>Followers</span>
                                                                            <h6> <Link >{item.followers}
                                                                            </Link> </h6>
                                                                        </div>
                                                                    </div>
                                                                    <div className="price">
                                                                        <span>{market_type === 1 ? 'Current Bid' : 'Current Price'}</span>
                                                                        <h5> {item.price}</h5>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </SwiperSlide>
                                    ))
                                }
                            </Swiper>
                        </div>
                    </div>
                </div>
            </section>
            <CardModal
                tokenIds={c_tokenId}
                maxcount={count}
                _currentprice={cprice}
                market_type={market_type}
                show={modalShow}
                onHide={() => setModalShow(false)}
            />
        </Fragment>

    );
}

LiveAuction.propTypes = {
    data: PropTypes.array.isRequired,
}


export default LiveAuction;
