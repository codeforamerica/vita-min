module StateFile
  module Questions
    class ConfirmationController < QuestionsController
      def show_xml
        submission = EfileSubmission.where(data_source: current_intake).first
        builder_response = current_intake.builder_class.build(submission)
        builder_response.errors.present? ? render(plain: builder_response.errors.join("\n") + "\n\n" + builder_response.document.to_xml) : render(xml: builder_response.document)
      end

      def explain_calculations
        # fixes Rails hot reload, see method source gem PR #73
        if Rails.env.development?
          MethodSource.instance_variable_set(:@lines_for_file, {})
        end
        @calculator = current_intake.tax_calculator(include_source: true)
        @calculator.calculate
      end

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
