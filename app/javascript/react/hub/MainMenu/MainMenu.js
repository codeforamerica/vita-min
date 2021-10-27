import React, { useState, useEffect } from "react"
import PropTypes from "prop-types"
import ToggleImg from 'icons/toggle.svg'

function MainMenu(props) {
    const initialMenuState = localStorage.getItem("hub.menu.expanded") == "true"
    const [expanded, toggleMenu] = useState(initialMenuState)
    let { current_user } = props

    useEffect(() => {
        localStorage.setItem("hub.menu.expanded", expanded)
    }, [expanded])

    const wrapperStyles = {
        height: "100%",
        zIndex: 1,
        width: expanded ? "250px" : "75px",
        background: "#2D2E2F",
        padding: 20,
        color: "white"
    }

    const containerStyles = {
        position: "fixed"
    }

    return (
        <div style={wrapperStyles}>
            <div style={containerStyles}>
                <div className="spacing-below-25" onClick={() => toggleMenu(!expanded)}>
                    <img src={ToggleImg} alt={"toggle menu"}/>
                </div>
                {expanded && <span>Welcome, {current_user.name}</span>}
                <div>
                    <div>
                        <a href={props.my_clients_link}>My Clients</a>
                    </div>

                    <div>
                        <a href={props.all_clients_link}>All Clients</a>
                    </div>

                    <div>
                        <a href={props.notifications_link}>Notifications</a>
                    </div>

                    <div>
                        <a href={props.profile_link}>My Profile</a>
                    </div>
                </div>
            </div>
        </div>
    )
}

MainMenu.propTypes = {
    something: PropTypes.string
};
export default MainMenu
