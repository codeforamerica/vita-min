module Hub
  module StateFile
    class EfileSubmissionsController < Hub::StateFile::BaseController
      load_and_authorize_resource
      before_action :load_efile_submissions, only: [:index]

      def index
        join_sql = ::StateFile::StateInformationService.active_state_codes.map do |_state_code|
          "SELECT state_file_#{_state_code}_intakes.id as intake_id, 'StateFile#{_state_code.to_s.titleize}Intake' as ds_type, '#{_state_code}' as data_source_state_code, state_file_#{_state_code}_intakes.email_address FROM state_file_#{_state_code}_intakes"
        end
        join_sql = "INNER JOIN (#{join_sql.join(" UNION ")}) data_source ON efile_submissions.data_source_id = data_source.intake_id and efile_submissions.data_source_type = data_source.ds_type"
        @efile_submissions = @efile_submissions.joins(join_sql).select("efile_submissions.*, data_source.*")
        search = params[:search]
        if search.present?
          query = "email_address LIKE ? OR irs_submission_id LIKE ?"
          query_args = ["%#{search}%", "%#{search}%"]
          if search.to_i.to_s == search && search.to_i.abs < (2 ** 32)
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
        @efile_submissions_same_intake.each do |efile_submission_same_intake|
          authorize! :read, efile_submission_same_intake
        end
        @valid_transitions = EfileSubmissionStateMachine.states.filter do |state|
          next if %w[failed rejected].include?(state) && acts_like_production?
          @efile_submission.can_transition_to?(state)
        end
      end

      def show_xml
        return nil if acts_like_production?

        submission = EfileSubmission.find(params[:efile_submission_id])
        authorize! :read, submission
        builder = ::StateFile::StateInformationService.submission_builder_class(submission.data_source.state_code)
        builder_response = builder.build(submission)
        builder_response.errors.present? ? render(plain: builder_response.errors.join("\n") + "\n\n" + builder_response.document.to_xml) : render(xml: builder_response.document)
      end

      def show_df_xml
        return nil if acts_like_production?

        submission = EfileSubmission.find(params[:efile_submission_id])
        authorize! :read, submission
        response = submission.data_source.raw_direct_file_data
        render(xml: response)
      end

      def show_pdf
        submission = EfileSubmission.find(params[:efile_submission_id])
        error_redirect and return unless submission.present?

        authorize! :read, submission

        send_data submission.generate_filing_pdf.read, filename: "#{params[:efile_submission_id]}_submission.pdf", disposition: 'inline'
      end

      def state_counts
        intake_classes = current_user.state_file_nj_staff? ? "StateFileNjIntake" : ::StateFile::StateInformationService.state_intake_class_names.excluding("StateFileNjIntake").join("','")
        @efile_submission_state_counts = EfileSubmission.statefile_state_counts(except: %w[new resubmitted ready_to_resubmit], intake_classes: intake_classes)
        respond_to :js
      end

      def transition_to
        to_state = params[:to_state]
        if %w[failed rejected].include?(to_state) && acts_like_production?
          flash[:error] = "Transition to #{to_state} failed"
          redirect_to hub_state_file_efile_submission_path(id: @efile_submission.id)
          return
        end

        authorize! :update, @efile_submission
        metadata = { initiated_by_id: current_user.id }
        if to_state == "rejected"
          if params[:auto_cancel]
            metadata[:error_code] = EfileError.where(service_type: "state_file_#{@efile_submission.data_source.state_code}", auto_cancel: true).last.code
          elsif params[:auto_wait]
            metadata[:error_code] = EfileError.where(service_type: "state_file_#{@efile_submission.data_source.state_code}", auto_wait: true).last.code
          else
            metadata[:error_code] = EfileError.where(service_type: "state_file_#{@efile_submission.data_source.state_code}", auto_cancel: false, auto_wait: false).last.code
          end
        end
        if @efile_submission.transition_to!(to_state, metadata)
          flash[:notice] = "Transitioned to #{to_state}"
        else
          flash[:error] = "Transition to #{to_state} failed"
        end
        redirect_to hub_state_file_efile_submission_path(id: @efile_submission.id)
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
