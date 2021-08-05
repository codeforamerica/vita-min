import consumer from "../channels/consumer";
import { callback, getChannelName } from "../channels/client_channel";
import { initNestedAttributesListeners } from "../lib/nested_attributes";
import helpers from "../helpers";
import { initTakeActionOnChangeHandlers } from "../lib/dynamic_take_action_changes";
import { initMetricsTableSortAndFilter } from "../lib/metrics_table_sort";
import { documentSubmittingIndicator } from "../lib/document_submitting_indicator";
import { initStateRoutingsListeners } from "../lib/state_routings";
import tooltip from "../components/tooltip";
import { initTaggableNote, initMultiSelectVitaPartner } from '../lib/tagging';
import { initBulkAction } from "../lib/bulk_action";
import { getEfileSecurityInformation } from "../lib/efile_security_information";
const Listeners =  (function(){
    return {
        init: function () {
            window.addEventListener("load", function() {
                if (!window.appData) {
                    return;
                }

                documentSubmittingIndicator.init(); // extend styling on honeyCrisp's default ajax upload functionality.

                if (window.appData.controller_action == "Hub::Users::InvitationsController#edit") {
                    helpers.setDefaultTimezone();
                }

                if (window.appData.controller_action == "Hub::MessagesController#index") {
                    consumer.subscriptions.create(getChannelName(window.location.href), callback);
                }

                if (["Hub::ClientsController#edit_take_action", "Hub::ClientsController#update_take_action"].includes(window.appData.controller_action)) {
                    initTakeActionOnChangeHandlers("take_action");
                }

                if (["Hub::BulkActions::ChangeAssigneeAndStatusController#edit", "Hub::BulkActions::ChangeAssigneeAndStatusController#update"].includes(window.appData.controller_action)) {
                    initTakeActionOnChangeHandlers("bulk_action");
                }

                if(["Hub::StateRoutingsController#edit", "Hub::StateRoutingsController#update"].includes(window.appData.controller_action)) {
                    initStateRoutingsListeners();
                }

                if(window.appData.controller_action == "Ctc::Questions::LegalConsentController#edit") {
                    getEfileSecurityInformation('ctc_legal_consent_form');
                }

                if(window.appData.controller_action == "Ctc::Questions::ConfirmLegalController#edit") {
                    getEfileSecurityInformation('ctc_confirm_legal_form');
                }

                if (document.querySelector('.taggable-note')) {
                    initTaggableNote();
                }
                if (document.querySelector('.multi-select-vita-partner')) {
                    initMultiSelectVitaPartner();
                }
                initMetricsTableSortAndFilter();
                // enables the link_to_add_fields and link_to_remove_fields helper methods to work globally
                initNestedAttributesListeners();

                tooltip.init();

                if (
                    document.querySelector('#take-action-footer') &&
                    document.querySelector('#bulk-edit-select-all') &&
                    document.querySelector('#take-action-form')
                ) {
                    initBulkAction();
                }
            });
        }
    }
})();

export default Listeners;
