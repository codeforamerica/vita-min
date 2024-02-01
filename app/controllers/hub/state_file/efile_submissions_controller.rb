module Hub
  module StateFile
    class EfileSubmissionsController < Hub::StateFile::BaseController
      load_and_authorize_resource
      before_action :load_efile_submissions, only: [:index]

      def index
        @efile_submissions = @efile_submissions.includes(:efile_submission_transitions).reorder(created_at: :desc).paginate(page: params[:page], per_page: 30)
        @efile_submissions = @efile_submissions.in_state(params[:status]) if params[:status].present?
        # @efile_submission_state_counts = state_counts
      end

      def show
        @efile_submissions_same_intake = EfileSubmission.where(data_source: @efile_submission.data_source).where.not(id: @efile_submission.id)
        authorize! :read, @efile_submissions_same_intake
      end

      def show_xml
        return nil if Rails.env.production? || Rails.env.staging?

        submission = EfileSubmission.find(params[:efile_submission_id])
        builder_response = case submission.data_source.state_code
                           when "ny"
                             SubmissionBuilder::Ty2022::States::Ny::IndividualReturn.build(submission)
                           when "az"
                             SubmissionBuilder::Ty2022::States::Az::IndividualReturn.build(submission)
                           end
        builder_response.errors.present? ? render(plain: builder_response.errors.join("\n") + "\n\n" + builder_response.document.to_xml) : render(xml: builder_response.document)
      end

      def show_df_xml
        return nil if Rails.env.production? || Rails.env.staging?

        response = EfileSubmission.find(params[:efile_submission_id]).data_source.raw_direct_file_data
        render(xml: response)
      end

      def state_counts
        # binding.pry
        @efile_submission_state_counts = EfileSubmission.statefile_state_counts(except: %w[new resubmitted ready_to_resubmit])
        respond_to :js
      end

      private

      def load_efile_submissions
        @efile_submissions = @efile_submissions.for_state_filing
      end
    end
  end
end
