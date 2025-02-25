module StateFile
  module ArchivedIntakes
    class ArchivedIntakeController < ApplicationController
      before_action :check_feature_flag
      def current_archived_intake
        return unless session[:email_address].present?
        email = session[:email_address].downcase
        existing = StateFileArchivedIntake.find_by("LOWER(email_address) = ?", email)
        existing || StateFileArchivedIntake.create(email_address: email)
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

      def is_intake_locked
        if current_archived_intake.nil? || current_archived_intake.access_locked? || current_archived_intake.permanently_locked_at.present?
          redirect_to state_file_archived_intakes_verification_error_path
        end
      end
    end
  end
end
