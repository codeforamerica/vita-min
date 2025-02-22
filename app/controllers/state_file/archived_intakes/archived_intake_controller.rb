module StateFile
  module ArchivedIntakes
    class ArchivedIntakeController < ApplicationController
      before_action :check_feature_flag
      def current_request
        request = StateFileArchivedIntake.where("LOWER(email_address) = LOWER(?)", session[:email_address]).first
        if request
          return request
        end

        StateFileArchivedIntakeRequest.find_or_create_by(email_address: session[:email_address])
      end

      def create_state_file_access_log(event_type)
        StateFileArchivedIntakeAccessLog.create!(
          event_type: event_type,
          state_file_archived_intake_request: current_request,
          state_file_archived_intake: current_request
        )
      end


      def check_feature_flag
        unless Flipper.enabled?(:get_your_pdf)
          redirect_to root_path
        end
      end

      def is_request_locked
        if current_request.access_locked? || current_archived_intake&.permanently_locked_at.present?
          redirect_to state_file_archived_intakes_verification_error_path
        end
      end
    end
  end
end
