module StateFile
  module ArchivedIntakes
    class PdfsController < ArchivedIntakeController
      before_action :check_feature_flag
      before_action :require_archived_intake_email
      before_action :require_archived_intake_verified


      def index
        # @prior_year_intake = StateFileArchivedIntake.last
        @prior_year_intake = StateFileArchivedIntake.find_by!(email_address: current_request.email_address)
        @pdf_url = @prior_year_intake.submission_pdf.url(expires_in: 30.minutes, disposition: "inline")
      end

      private

      def require_archived_intake_email
        return if session[:email_address].present?

        redirect_to root_path
      end

      # TODO - implement when ssn code is merged
      def require_archived_intake_verified
      end
    end
  end
end
