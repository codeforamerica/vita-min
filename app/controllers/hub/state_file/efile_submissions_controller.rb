module Hub
  module StateFile
    class EfileSubmissionsController < Hub::BaseController
      before_action :require_state_file
      load_and_authorize_resource
      before_action :load_efile_submissions, only: [:index]
      layout "hub"

      def index
        @efile_submissions = @efile_submissions.includes(:efile_submission_transitions).reorder(created_at: :desc).paginate(page: params[:page], per_page: 30)
        @efile_submissions = @efile_submissions.in_state(params[:status]) if params[:status].present?
      end

      def show
        @efile_submissions_same_intake = EfileSubmission.where(data_source: @efile_submission.data_source).where.not(id: @efile_submission.id)
        authorize! :read, @efile_submissions_same_intake
      end

      private

      def load_efile_submissions
        @efile_submissions = @efile_submissions.for_state_filing
      end
    end
  end
end
