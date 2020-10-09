const helpers = require("helpers");

function init() {
    document.addEventListener("DOMContentLoaded", function() {
        if (window.appData.controller_action == "Users::InvitationsController#edit") {
            helpers.setDefaultTimezone();
        }
    });
}

module.exports = init;
