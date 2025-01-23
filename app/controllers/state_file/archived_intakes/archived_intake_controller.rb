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

      def address_challenge_set
        (current_request.fake_addresses.push(current_archived_intake.full_address)).shuffle
      end

      def check_feature_flag
        unless Flipper.enabled?(:get_your_pdf)
          redirect_to root_path
        end
      end

      def is_request_locked
        if current_request.access_locked?
          redirect_to state_file_archived_intakes_verification_error_path
        end
      end
    end
  end
end
