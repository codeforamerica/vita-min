import React, { useState, useEffect } from "react"
import PropTypes from "prop-types"
import { useCookies } from 'react-cookie'

function MainMenu(props) {
  const initialMenuState = localStorage.getItem("hub.menu.expanded") == "true"
  const [expanded, toggleMenu] = useState(initialMenuState)
  let { current_user } = props

  useEffect(() => {
    localStorage.setItem("hub.menu.expanded", expanded)
  }, [expanded])

  return (
    <div className="main-header" style={{height: "100%", width: expanded ? "250px" : "75px"}}>
      {expanded && <span>Welcome, {current_user.name}</span>}
      <div onClick={() => toggleMenu(!expanded)}>close</div>

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
  )
}

MainMenu.propTypes = {
  something: PropTypes.string
};
export default MainMenu
