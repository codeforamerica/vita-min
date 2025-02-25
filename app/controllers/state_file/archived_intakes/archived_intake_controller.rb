module StateFile
  module ArchivedIntakes
    class ArchivedIntakeController < ApplicationController
      before_action :check_feature_flag
      def current_archived_intake
        return unless session[:email_address].present?
        StateFileArchivedIntake.where("LOWER(email_address) = LOWER(?)", session[:email_address])
                               .first_or_create(email_address: session[:email_address].downcase)
      end

      def create_state_file_access_log(event_type)
        StateFileArchivedIntakeAccessLog.create!(
          event_type: event_type,
          state_file_archived_intake: current_archived_intake
        )
      end


      def check_feature_flag
        unless Flipper.enabled?(:get_your_pdf)
          redirect_to root_path
        end
      end

      def is_request_locked
        if current_archived_intake.nil? || current_archived_intake.access_locked? || current_archived_intake.permanently_locked_at.present?
          redirect_to state_file_archived_intakes_verification_error_path
        end
      end
    end
  end
end
