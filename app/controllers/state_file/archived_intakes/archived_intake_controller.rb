module StateFile
  module ArchivedIntakes
    class ArchivedIntakeController < ApplicationController
      before_action :check_feature_flag
      def current_request
        StateFileArchivedIntakeRequest.find_by(ip_address: ip_for_irs, email_address: session[:email_address])
      end

      def current_archived_intake
        current_request.state_file_archived_intake
      end

      def create_state_file_access_log(event_type)
        StateFileArchivedIntakeAccessLog.create!(
          event_type: event_type,
          state_file_archived_intake_request: current_request
        )
      end

      def check_feature_flag
        unless Flipper.enabled?(:get_your_pdf)
          redirect_to root_path
        end
      end
    end
  end
end
