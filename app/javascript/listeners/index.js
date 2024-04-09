import consumer from "../channels/consumer";
import { callback, getChannelName } from "../channels/client_channel";
import { initNestedAttributesListeners } from "../lib/nested_attributes";
import helpers from "../helpers";
import { initTakeActionOnChangeHandlers } from "../lib/dynamic_take_action_changes";
import { initMetricsTableSortAndFilter } from "../lib/metrics_table_sort";
import { documentSubmittingIndicator } from "../lib/document_submitting_indicator";
import { initStateRoutingsListeners } from "../lib/state_routings";
import tooltip from "../components/tooltip";
import { initTaggableNote, initMultiSelectVitaPartner, initMultiSelectState, initSelectVitaPartner } from '../lib/tagging';
import { initBulkAction } from "../lib/bulk_action";
import { getEfileSecurityInformation } from "../lib/efile_security_information";
import { initTINTypeSelector } from "../lib/tin_type_selector";
import { addTargetBlankToLinks } from "../lib/action_text_target_blank";
import { limitTextMessageLength } from "../lib/text_message_length_limiter";
import { initServiceComparisonComponent } from "../lib/service_comparison_component";
import { fetchEfileStateCounts } from "../lib/fetch_efile_state_counts";
import { fetchStateFileEfileStateCounts } from "../lib/fetch_statefile_efile_state_counts";
import ClientMenuComponent from "../components/ClientMenuComponent";
import WarningForDateComponent from "../components/WarningForDateComponent";
import WarningForSelectComponent from "../components/WarningForSelectComponent";
import MixpanelEventTracking from "../lib/mixpanel_event_tracking";
import IntercomBehavior from "../lib/intercom_behavior";
const Listeners =  (function(){
    return {
        init: function () {
            window.addEventListener("load", function() {
                IntercomBehavior.openIfAskedFor();
                MixpanelEventTracking.listenForTrackedClicks();
                const { controllerAction } = document.querySelector("#mixpanelData")?.dataset || {};
                ClientMenuComponent();
                WarningForDateComponent();
                WarningForSelectComponent();

                documentSubmittingIndicator.init(); // extend styling on honeyCrisp's default ajax upload functionality.

                if (controllerAction === "Hub::Users::InvitationsController#edit") {
                    helpers.setDefaultTimezone();
                }

                if (controllerAction == "Hub::MessagesController#index") {
                    consumer.subscriptions.create(getChannelName(window.location.href), callback);
                }

                if (["Hub::ClientsController#edit_take_action", "Hub::ClientsController#update_take_action"].includes(controllerAction)) {
                    initTakeActionOnChangeHandlers("take_action");
                }

                if (["Hub::BulkActions::ChangeAssigneeAndStatusController#edit", "Hub::BulkActions::ChangeAssigneeAndStatusController#update"].includes(controllerAction)) {
                    initTakeActionOnChangeHandlers("bulk_action");
                }

                if(["Hub::StateRoutingsController#edit", "Hub::StateRoutingsController#update"].includes(controllerAction)) {
                    initStateRoutingsListeners();
                }

                if(document.querySelector("form[data-efile-security-information='true']")) {
                    const form = document.querySelector("form[data-efile-security-information='true']");
                    getEfileSecurityInformation(form.dataset.formName);
                }

                if(controllerAction == "Hub::EfileSubmissionsController#index") {
                    fetchEfileStateCounts();
                }

                if(controllerAction == "Hub::StateFile::EfileSubmissionsController#index") {
                    fetchStateFileEfileStateCounts();
                }

                if (document.querySelector('.taggable-note')) {
                    initTaggableNote();
                }
                if (document.querySelector('.multi-select-vita-partner')) {
                    initMultiSelectVitaPartner();
                }
                if (document.querySelector('.select-vita-partner')) {
                    initSelectVitaPartner();
                }
                if (document.querySelector('.multi-select-state')) {
                    initMultiSelectState();
                }
                if (document.querySelector('.trix-content')) {
                    addTargetBlankToLinks();
                }

                if (window.TINTypeSelector && window.SSNEmploymentCheckboxSelector) {
                    initTINTypeSelector();
                }

                if (document.querySelector('textarea.text-message-body')) {
                    limitTextMessageLength();
                }
                initMetricsTableSortAndFilter();
                // enables the link_to_add_fields and link_to_remove_fields helper methods to work globally
                initNestedAttributesListeners();

                tooltip.init();

                if (document.querySelector('div.comparison-component')) {
                    initServiceComparisonComponent();
                }

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
