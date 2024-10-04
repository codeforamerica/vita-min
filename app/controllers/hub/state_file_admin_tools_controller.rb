module Hub
  class StateFileAdminToolsController < Hub::BaseController
    layout "hub"
    load_and_authorize_resource class: false

    def index
      @actions = [
        [Hub::StateFile::EfileSubmissionsController.to_path_helper(action: :index), "Efile Submissions"],
        [Hub::StateFile::FaqCategoriesController.to_path_helper(action: :index), "FAQ (Frequently Asked Questions)"],
        [Hub::StateFile::AutomatedMessagesController.to_path_helper(action: :index), "Automated Messages"],
        [Hub::StateFile::EfileErrorsController.to_path_helper(action: :index), "Efile Errors"],
      ]
    end
  end
end