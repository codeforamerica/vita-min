import consumer from "../channels/consumer";
import { callback, getChannelName } from "../channels/client_channel";
import { initNestedAttributesListeners } from "../lib/nested_attributes";
import helpers from "../helpers";
import { initTakeActionOnChangeHandlers } from "../lib/dynamic_take_action_changes";
import { initMetricsTableSortAndFilter } from "../lib/metrics_table_sort";
import { documentSubmittingIndicator } from "../lib/document_submitting_indicator";
import { initStateRoutingsListeners } from "../lib/state_routings";
import tooltip from "../components/tooltip";

const Listeners =  (function(){
    return {
        init: function () {
            document.addEventListener("DOMContentLoaded", function() {
                documentSubmittingIndicator.init(); // extend styling on honeyCrisp's default ajax upload functionality.

                if (window.appData.controller_action == "Hub::Users::InvitationsController#edit") {
                    helpers.setDefaultTimezone();
                }
                if (window.appData.controller_action == "Hub::MessagesController#index") {
                    consumer.subscriptions.create(getChannelName(window.location.href), callback);
                }

                if (["Hub::ClientsController#edit_take_action", "Hub::ClientsController#update_take_action"].includes(window.appData.controller_action)) {
                    initTakeActionOnChangeHandlers();
                }

                if(["Hub::StateRoutingsController#edit", "Hub::StateRoutingsController#update"].includes(window.appData.controller_action)) {
                    initStateRoutingsListeners();
                }

                initMetricsTableSortAndFilter();
                // enables the link_to_add_fields and link_to_remove_fields helper methods to work globally
                initNestedAttributesListeners();

                tooltip.init();
            });
        }
    }
})();

export default Listeners;
