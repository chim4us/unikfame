import React, { useRef, useState, useEffect, useContext } from 'react';
import { Link, useLocation } from "react-router-dom";
import menus from "../../pages/menu";
import unikfamelogo from '../../assets/images/logo/nft-logo.png';
import { LoginContext } from '../../context/LoginContext';
import { useNavigate } from 'react-router-dom';
import { use } from 'chai';


const Header = (props) => {
    const { fetchFireData, account, userCard, users, changeAccount, balance } = useContext(LoginContext);
    const { pathname } = useLocation();
    const [name, setName] = useState("");

    const headerRef = useRef(null)
    useEffect(() => {
        let exist = users.filter((e) => e.walletId === account);
        if (exist.length)
            setName(exist[0].displayName);

        window.addEventListener('scroll', isSticky);
        return () => {
            window.removeEventListener('scroll', isSticky);
        };
    }, []);
    useEffect(() => {
        let exist = users.filter((e) => e.walletId === account);
        if (exist.length)
            setName(exist[0].displayName);
    }, [account])
    const isSticky = (e) => {
        const header = document.querySelector('.js-header');
        const scrollTop = window.scrollY;
        scrollTop >= 300 ? header.classList.add('is-fixed') : header.classList.remove('is-fixed');
        scrollTop >= 400 ? header.classList.add('is-small') : header.classList.remove('is-small');
    };

    const menuLeft = useRef(null)
    const btnToggle = useRef(null)

    const menuToggle = () => {
        menuLeft.current.classList.toggle('active');
        btnToggle.current.classList.toggle('active');
    }

    const [activeIndex, setActiveIndex] = useState(null);    
    const handleOnClick = index => {
        setActiveIndex(index);
    };

    const navigate = useNavigate();
    const walletConnect = async () => {
        if (account === "Log In / Sign Up")
            changeAccount()
        else
            navigate("/my-profile")
    }
    return (
        <header id="header_main" className="header_1 header_2 style2 js-header" ref={headerRef}>
            <div className="themesflat-container">
                <div className="row">
                    <div className="col-md-12">
                        <div id="site-header-inner">
                            <div className="wrap-box d-flex justify-content-between">
                                <div id="site-logo" className="clearfix">
                                    <div id="site-logo-inner">
                                        <Link to="/" rel="home" className="main-logo unikfame-logo">
                                            <img className='logo-light' id="logo_header" src={unikfamelogo} alt="nft-gaming" />
                                            <div className='d-flex beta-logo'>
                                                <h3 className="logo-text">UnikFame</h3> <p className="beta-logo-text">Beta</p>
                                            </div>
                                        </Link>
                                    </div>
                                </div>
                                <div className="mobile-button" ref={btnToggle} onClick={menuToggle}><span></span></div>
                                <div className="header-right form-inline">
                                    <nav id="main-nav" className="main-nav" ref={menuLeft} >
                                        <ul id="menu-primary-menu" className="menu">
                                            {
                                                menus.slice(0, 2).map((data, index) => (
                                                    <li key={index} /*onClick={() => handleOnClick(index)} */ className={`menu-item ${data.namesub ? 'menu-item-has-children' : ''} `}   >
                                                        <Link to={data.links}>{data.name}</Link>
                                                        {
                                                            data.namesub &&
                                                            <ul className="sub-menu" >
                                                                {
                                                                    data.namesub.map((submenu) => (
                                                                        <li key={submenu.id} className={
                                                                            pathname === submenu.links
                                                                                ? "menu-item current-item"
                                                                                : "menu-item"
                                                                        }><Link to={submenu.links}>{submenu.sub}</Link></li>
                                                                    ))
                                                                }
                                                            </ul>
                                                        }

                                                    </li>
                                                ))
                                            }
                                            <li className="menu-item menu-item-has-children">
                                                <div onClick={() => { walletConnect(); }} className='profile-menu'>{name != "" ? name : account} {account == "Log In / Sign Up" ? "" : "(" + Number(balance).toFixed(3) + ")"}</div>
                                                {
                                                    menus[2].namesub && account != "Log In / Sign Up" &&
                                                    <ul className="sub-menu" >
                                                        {
                                                            menus[2].namesub.map((submenu) => (
                                                                <li key={submenu.id} className={
                                                                    pathname === submenu.links
                                                                        ? "menu-item current-item"
                                                                        : "menu-item"
                                                                }><Link to={submenu.links}>{submenu.sub}</Link></li>
                                                            ))
                                                        }
                                                    </ul>
                                                }
                                            </li>
                                        </ul>
                                    </nav>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </header>
    );
}

export default Header;
