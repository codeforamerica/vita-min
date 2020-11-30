import consumer from "../channels/consumer";
import { callback, getChannelName } from "../channels/client_channel";
import { initNestedAttributesListeners } from "../lib/nested_attributes";
import helpers from "helpers";

export function initListeners() {
    document.addEventListener("DOMContentLoaded", function() {
        if (window.appData.controller_action == "Hub::Users::InvitationsController#edit") {
            helpers.setDefaultTimezone();
        }
        if (window.appData.controller_action == "Hub::MessagesController#index") {
            consumer.subscriptions.create(getChannelName(window.location.href), callback);
        }

        // enables the link_to_add_fields and link_to_remove_fields helper methods to work globally
        initNestedAttributesListeners();
    });
}
