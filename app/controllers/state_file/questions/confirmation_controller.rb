module StateFile
  module Questions
    class ConfirmationController < QuestionsController
      def show_xml
        submission = EfileSubmission.where(data_source: current_intake).first
        builder_response = case params[:us_state]
                           when "ny"
                             SubmissionBuilder::Ty2022::States::Ny::IndividualReturn.build(submission)
                           when "az"
                             SubmissionBuilder::Ty2022::States::Az::IndividualReturn.build(submission)
                           end
        builder_response.errors.present? ? render(plain: builder_response.errors.join("\n") + "\n\n" + builder_response.document.to_xml) : render(xml: builder_response.document)
      end

      # possible TODO (from a chore written by Travis): Rewrite source display in Explain Calculations page to use the parser gem
      # Currently we rely on method(...).source which comes from the method-source gem and is somewhat shady.
      # It relies on .source_location, a core ruby method that returns the line number a given method is defined on. Then it uses eval on progressively longer chunks of code starting from that line until it finds a statement that doesn't crash. Probably slow?
      #
      # It might be better for us to use the parser gem and use source_location to find the right text from the AST. This would bypass the sketchy use of eval and give us finer control over the output.
      #
      # Right now for a line like this:
      # set_line(:LINE1, -> { @some_field * 2 })
      # asking .source of the lambda returns the whole line, set_line and all. This could be improved if we had finer grained control of the code.
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
