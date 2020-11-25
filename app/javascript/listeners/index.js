import consumer from "../channels/consumer";
import {callback, getChannelName} from "../channels/client_channel";
import {bindStatusChangeEventListener} from "../statuses";

const helpers = require("helpers");

export function initListeners() {
    document.addEventListener("DOMContentLoaded", function () {
        if (window.appData.controller_action == "Users::InvitationsController#edit") {
            helpers.setDefaultTimezone();
        }
        if (window.appData.controller_action == "Hub::MessagesController#index") {
            consumer.subscriptions.create(getChannelName(window.location.href), callback);
        }
        if (window.appData.controller_action == "Hub::TaxReturnsController#edit_status") {
            bindStatusChangeEventListener("#hub_take_action_form_status");
        }
    });
}
