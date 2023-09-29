module StateFile
  module Questions
    class ConfirmationController < QuestionsController
      layout "state_file/question"

      def show_xml
        submission = EfileSubmission.where(data_source: current_intake).first
        submission_content = case params[:us_state]
                             when "ny"
                               SubmissionBuilder::Ty2022::States::Ny::IndividualReturn.build(submission).document
                             when "az"
                               SubmissionBuilder::Ty2022::States::Az::IndividualReturn.build(submission).document
                             end
        render xml: submission_content
      end

      def explain_calculations
        # fixes Rails hot reload, see method source gem PR #73
        if Rails.env.development?
          MethodSource.instance_variable_set(:@lines_for_file, {})
        end
        @calculator = current_intake.tax_calculator
        @calculator.calculate
      end

      def illustration_path; end

      private

      def next_path
        root_path
      end

      def after_update_success
        session[:state_file_intake] = nil
        flash[:notice] = "Submitted efile submission"
      end
    end
  end
end
