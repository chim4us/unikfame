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

const MarketHeader = props => {
    const page_type = props.page_type;    
    const data = [
        ["/live-markets", "FEATURED DROP"],
        ["/live-auctions", "ACTIVE LISTINGS"],
        ["/activity", "LATEST SALES"],
    ]

    return (
        <section className="flat-title-page inner">
            <div className="themesflat-container">
                <div className="row">
                    <div className="col-md-12">
                        <div className="page-title-heading mg-bt-12">
                            <h1 className="heading text-center">Marketplace</h1>
                        </div>
                    </div>
                    <div className="breadcrumbs style2">
                        <ul>
                            {
                                data.map((e, i) => {
                                    let cname = "";
                                    if(i == page_type)
                                        cname = "listwhite";
                                    return <li className= {cname}><Link to={e[0]}>{e[1]}</Link></li>;
                                })
                            }
                        </ul>
                    </div>
                </div>
            </div>
        </section>
    );
}

MarketHeader.propTypes = {
    data: PropTypes.array.isRequired,
}


export default MarketHeader;
