import React, { useState, useEffect } from 'react';

function MenuItem(props) {
    const activeMenuItem = 'hub.menu.active-menu-item'
    let isActive = localStorage.getItem(activeMenuItem) == props.link

    const [active, setActive] = useState(isActive);

    // on mount, ensure there is a value in localStorage for menu item
    useEffect(() => {
        let storedLink = localStorage.getItem(activeMenuItem)
        if(window.location.pathname.indexOf(storedLink) == -1) {
            localStorage.setItem(activeMenuItem, props.link)
        }
        if(!storedLink) {
            localStorage.setItem(activeMenuItem, props.link)
        }
    }, [])

    useEffect(() => {
        if(active) {
            localStorage.setItem(activeMenuItem, props.link)
        }
    }, [active])

    return (
        <a className={`menu-item ${active && 'active'} ${props.expanded ? 'expanded' : 'collapsed'}`} href={props.link} onClick={() => setActive(true)}>
            <img src={props.icon} alt={""} />
            <div>{props.label}</div>
        </a>
    )
}

export default MenuItem