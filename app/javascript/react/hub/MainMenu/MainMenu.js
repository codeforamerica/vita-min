import React, { useState, useEffect } from "react"
import PropTypes from "prop-types"
import ToggleImg from 'icons/toggle.svg'
import MenuItem from './MenuItem'

function MainMenu(props) {
    const initialMenuState = localStorage.getItem("hub.menu.expanded") == "true"
    const [expanded, toggleMenu] = useState(initialMenuState)
    let { current_user } = props
    let firstName = current_user.name.split(" ")[0]

    useEffect(() => {
        localStorage.setItem("hub.menu.expanded", expanded)
    }, [expanded])

    return (
        <div className={`left-menu ${expanded && 'expanded'}`}>
            <div className="container">
                <span className="toggle" onClick={() => toggleMenu(!expanded)}>
                    <img src={ToggleImg} alt={"toggle menu"}/>
                </span>
                <div>
                    <MenuItem link={props.my_clients_link} label="My Clients" />
                    <MenuItem link={props.all_clients_link} label="All Clients" />
                    <MenuItem link={props.notifications_link} label="My Updates" />
                    <MenuItem link={props.profile_link} label="My Profile" />
                    <MenuItem link={props.efile_link} label="CTC Efile" />
                </div>
                <div className={"bottom"}>
                    {expanded && <span>{firstName}</span>}
                </div>
            </div>
        </div>
    )
}

MainMenu.propTypes = {
    something: PropTypes.string
};
export default MainMenu
