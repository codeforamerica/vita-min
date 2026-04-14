module Hub
  module CampaignMessages
    class DashboardController < Hub::BaseController
      layout "hub"
      before_action :require_admin

      def index
        @actions = [
          [Hub::CampaignMessages::MonitorSmsController.to_path_helper(action: :show), "Monitor Campaign SMS"],
          [Hub::AutomatedMessagesController.to_path_helper(action: :index), "Monitor Campaign Emails"],
          [MetricsController.to_path_helper(action: :index), "Monitor Unsubscribes"],
          [Hub::BulkMessageCsvsController.to_path_helper(action: :index), "Send/Cancel Campaign-Message Batches"],
        ]

        # <!--  engineer only-->
      end

    end
  end
end