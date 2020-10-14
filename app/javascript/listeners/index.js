import consumer from "../channels/consumer";
import {callback, getChannelName} from "../channels/client_channel";

const helpers = require("helpers");

export function initListeners() {
    document.addEventListener("DOMContentLoaded", function() {
        if (window.appData.controller_action == "Users::InvitationsController#edit") {
            helpers.setDefaultTimezone();
        }
        if (window.appData.controller_action == "CaseManagement::MessagesController#index") {
            consumer.subscriptions.create(getChannelName(window.location.href), callback);
        }
    });
}
