import React, { useState, useEffect } from "react"
import PropTypes from "prop-types"
import ToggleImg from 'icons/toggle.svg'
import MyProfileImg from 'icons/my-profile.svg'
import NotificationsImg from 'icons/notifications.svg'
import MyClientsImg from 'icons/person-outline.svg'
import AllClientsImg from 'icons/people-outline.svg'
import LogoImg from 'checkbox-logo--white.png'
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
        <div className={`main-menu ${expanded && 'expanded'}`}>
            <div className="container">
                <span className={`toggle ${!expanded && 'collapsed'}`} onClick={() => toggleMenu(!expanded)}>
                    <img src={ToggleImg} alt="toggle menu" />
                </span>
                <div>
                    <div className={`logo ${!expanded && 'collapsed'}`}>
                        <img src={LogoImg} alt={""}/>
                        {expanded && <div className="logo-text">The Hub</div>}
                    </div>
                    <div>
                        <MenuItem link={props.all_clients_link}
                                  label="All Clients"
                                  icon={AllClientsImg}
                                  expanded={expanded}
                        />
                        <MenuItem link={props.my_clients_link}
                                  label="My Clients"
                                  icon={MyClientsImg}
                                  expanded={expanded}
                        />
                        <MenuItem link={props.notifications_link}
                                  label="My Updates"
                                  icon={NotificationsImg}
                                  expanded={expanded}
                        />
                        <MenuItem link={props.efile_link}
                                  label="CTC Efile"
                                  icon={NotificationsImg}
                                  expanded={expanded}
                        />
                    </div>
                </div>
                <div className={`bottom ${expanded ? "expanded" : "collapsed"}`}>
                    <a href={props.profile_link}>
                        <img width="24" src={MyProfileImg} alt="My Profile" />
                    </a>
                    {expanded &&
                    <a href={props.profile_link} className="name">
                        {current_user.name}
                    </a>
                    }
                    {!expanded &&
                    <a href={props.profile_link} className="name">
                        {firstName}
                    </a>
                    }

                    <a data-method="delete" href={props.signout_link}>
                        Sign out
                    </a>

                </div>
            </div>
        </div>
    )
}

MainMenu.propTypes = {
    something: PropTypes.string
};
export default MainMenu
