module StateFile
  module ArchivedIntakes
    class PdfsController < ArchivedIntakeController
      before_action :check_feature_flag
      before_action :is_intake_locked
      before_action :require_archived_intake_email
      before_action :require_archived_intake_email_code_verified
      before_action :require_archived_intake_ssn_verified
      before_action :require_mailing_address_verified
      before_action do
        if Rails.env.development? || Rails.env.test?
          ActiveStorage::Current.url_options = { protocol: request.protocol, host: request.host, port: request.port }
        end
      end

      def index
        @state_code = StateFileArchivedIntake.find_by!(email_address: current_archived_intake.email_address).state_code
        create_state_file_access_log("issued_pdf_download_link")
      end

      def log_and_redirect
        create_state_file_access_log("client_pdf_download_click")
        pdf_url = current_archived_intake.submission_pdf.url(expires_in: pdf_expiration_time, disposition: "inline")
        redirect_to pdf_url, allow_other_host: true
      end

      private

      def pdf_expiration_time
        if Rails.env.production?
          24.hours
        else
          10.minutes
        end
      end

      def require_archived_intake_email
        return if session[:email_address].present?

        redirect_to state_file_archived_intakes_verification_error_path
      end

      def require_archived_intake_email_code_verified
        return if session[:code_verified].present?

        redirect_to state_file_archived_intakes_verification_error_path
      end

      def require_archived_intake_ssn_verified
        return if session[:ssn_verified].present?

        redirect_to state_file_archived_intakes_verification_error_path
      end

      def require_mailing_address_verified
        return if session[:mailing_verified].present?

        redirect_to state_file_archived_intakes_verification_error_path
      end
    end
  end
end
