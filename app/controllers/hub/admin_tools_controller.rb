module Hub
  class AdminToolsController < Hub::BaseController
    layout "hub"
    load_and_authorize_resource class: false

    def index
      @actions = [
        [Hub::AdminTogglesController.to_path_helper(action: :index, name: AdminToggle::FORWARD_MESSAGES_TO_INTERCOM), "Intercom Message Forwarding"],
        [Hub::StateRoutingsController.to_path_helper(action: :index), "Routing"],
        [Hub::AutomatedMessagesController.to_path_helper(action: :index), "Automated Messages"],
        [MetricsController.to_path_helper(action: :index), "SLA Breaches"],
        [Hub::BulkMessageCsvsController.to_path_helper(action: :index), "Bulk messaging clients CSV upload"],
        [Hub::SignupSelectionsController.to_path_helper(action: :index), "Bulk messaging signups CSV upload"],
        [Hub::Admin::ExperimentsController.to_path_helper(action: :index), "Experiments"],
        [Hub::PortalStatesController.to_path_helper(action: :index), "Portal States"],
        [Hub::FaqCategoriesController.to_path_helper(action: :index), "Frequently Asked Questions"],
      ]
      if current_user.state_file_admin?
        @state_file_actions = [
          [Hub::StateFileController.to_path_helper(action: :index), "State File"]
        ]
      end
      @deprecated_actions = [
        [hub_verification_attempts_path, "Client Verification"],
        [hub_fraud_indicators_path, "Fraud Indicators"],
        [hub_efile_submissions_path, "E-file Dashboard"],
        [hub_efile_errors_path, "E-file Errors"],
      ]
    end
  end
end