module Hub
  class AdminToolsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    layout "hub"

    def index
      @actions = [
        [Hub::AdminTogglesController.to_path_helper(action: :index, name: AdminToggle::FORWARD_MESSAGES_TO_INTERCOM), "Intercom Message Forwarding"],
        [hub_state_routings_path, "Routing"],
        [hub_automated_messages_path, "Automated Messages"],
        [hub_metrics_path, "SLA Breaches"],
        [hub_verification_attempts_path, "Client Verification"],
        [hub_bulk_message_csvs_path, "Bulk messaging clients CSV upload"],
        [hub_signup_selections_path, "Bulk messaging signups CSV upload"],
        [hub_admin_experiments_path, "Experiments"],
      ]
      @deprecated_actions = [
        [hub_fraud_indicators_path, "Fraud Indicators"],
        [hub_efile_submissions_path, "E-file Dashboard"],
        [hub_efile_errors_path, "E-file Errors"],
      ]
    end
  end
end