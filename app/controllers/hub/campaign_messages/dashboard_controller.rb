module Hub
  module CampaignMessages
    class DashboardController < Hub::BaseController
      layout "hub"
      before_action :require_admin

      def index
        @actions = [
          [Hub::CampaignMessages::MonitorSmsController.to_path_helper(action: :show), "Monitor Campaign SMS"],
          [Hub::CampaignMessages::MonitorEmailsController.to_path_helper(action: :show), "Monitor Campaign Emails"],
          # [Hub::CampaignMessages::SendCampaignBatches.to_path_helper(action: :index), "Send/Cancel Campaign-Message Batches"],
        ]
      end

    end
  end
end