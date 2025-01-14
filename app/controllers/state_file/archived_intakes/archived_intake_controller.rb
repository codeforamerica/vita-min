module StateFile
  module ArchivedIntakes
    class ArchivedIntakeController < ApplicationController
      def current_request
        StateFileArchivedIntakeRequest.find_by(ip_address: ip_for_irs, email_address: session[:email_address])
      end

      def create_state_file_access_log(event_type)
        StateFileArchivedIntakeAccessLog.create!(
          event_type: event_type,
          state_file_archived_intake_request: current_request
        )
      end

      def check_feature_flag
        unless Flipper.enabled?(:get_your_pdf)
          # this redirect to be changed when we have an offboarding page
          redirect_to root_path
        end
      end
    end
  end
end