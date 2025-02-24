module StateFile
  module ArchivedIntakes
    class ArchivedIntakeController < ApplicationController
      layout "state_file"
      before_action :check_feature_flag
      def current_request
        request = StateFileArchivedIntakeRequest.where("ip_address = ? AND LOWER(email_address) = LOWER(?)", ip_for_irs, session[:email_address]).first
        unless request
          Rails.logger.warn "StateFileArchivedIntakeRequest not found for IP: #{ip_for_irs}, Email: #{session[:email_address]}"
          Sentry.capture_message "StateFileArchivedIntakeRequest not found for IP: #{ip_for_irs}, Email: #{session[:email_address]}"
        end
        request
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

      def is_request_locked
        if current_request.access_locked? || current_archived_intake&.permanently_locked_at.present?
          redirect_to state_file_archived_intakes_verification_error_path
        end
      end
    end
  end
end
