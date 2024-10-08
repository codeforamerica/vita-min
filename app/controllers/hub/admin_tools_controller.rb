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
        [Hub::FaqCategoriesController.to_path_helper(action: :index), "FAQ (Frequently Asked Questions)"],
      ]
    end
  end
end