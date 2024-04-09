module Hub
  module StateFile
    class EfileSubmissionsController < Hub::StateFile::BaseController
      load_and_authorize_resource
      before_action :load_efile_submissions, only: [:index]

      def index

        join_sql = StateFileBaseIntake::STATE_CODES.map do |state_code|
          "SELECT state_file_#{state_code}_intakes.id as intake_id, 'StateFile#{state_code.to_s.titleize}Intake' as ds_type, '#{state_code}' as data_source_state_code, state_file_#{state_code}_intakes.email_address FROM state_file_#{state_code}_intakes"
        end
        join_sql = "INNER JOIN (#{join_sql.join(" UNION ")}) data_source ON efile_submissions.id = data_source.intake_id and efile_submissions.data_source_type = data_source.ds_type"
        @efile_submissions = EfileSubmission.joins(join_sql).select("efile_submissions.*, data_source.*")

        search = params[:search]
        if search.present?
          query = "email_address LIKE ? OR irs_submission_id LIKE ?"
          query_args = ["%#{search}%", "%#{search}%"]
          if search.to_i.to_s == search && search.to_i.abs < (2 ** 23)
            query << " OR id=? OR intake_id=?"
            query_args.concat [search.to_i, search.to_i]
          end
          @efile_submissions = @efile_submissions.where(query, *query_args)
        end

        @efile_submissions = @efile_submissions.includes(:efile_submission_transitions).reorder(created_at: :desc).paginate(page: params[:page], per_page: 30)
        @efile_submissions = @efile_submissions.in_state(params[:status]) if params[:status].present?

      end

      def show
        @efile_submissions_same_intake = EfileSubmission.where(data_source: @efile_submission.data_source).where.not(id: @efile_submission.id)
        authorize! :read, @efile_submissions_same_intake
      end

      def show_xml
        return nil if acts_like_production?

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
        return nil if acts_like_production?

        response = EfileSubmission.find(params[:efile_submission_id]).data_source.raw_direct_file_data
        render(xml: response)
      end

      def show_pdf
        submission = EfileSubmission.find(params[:efile_submission_id])
        error_redirect and return unless submission.present?

        send_data submission.generate_filing_pdf.read, filename: "#{params[:efile_submission_id]}_submission.pdf", disposition: 'inline'
      end

      def state_counts
        @efile_submission_state_counts = EfileSubmission.statefile_state_counts(except: %w[new resubmitted ready_to_resubmit])
        respond_to :js
      end

      private

      def error_redirect
        flash[:alert] = "There was a problem generating the tax return pdf."
        redirect_back(fallback_location: request.referer)
      end

      def load_efile_submissions
        @efile_submissions = @efile_submissions.for_state_filing
      end
    end
  end
end
