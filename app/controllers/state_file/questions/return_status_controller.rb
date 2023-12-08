module StateFile
  module Questions
    class ReturnStatusController < AuthenticatedQuestionsController
      helper_method :return_status, :title, :reject_code, :reject_description

      def edit; end

      def title
        case return_status
        when 'accepted'
          I18n.t("state_file.questions.return_status.accepted.title")
        when 'rejected'
          I18n.t("state_file.questions.return_status.rejected.title")
        else
          I18n.t("state_file.questions.return_status.pending.title")
        end
      end

      def return_status
        # 'rejected'
        case current_intake.efile_submissions.last.current_state
        when 'accepted'
          'accepted'
        when 'rejected'
          'rejected'
        else
          'pending'
        end
      end

      def e_file_error
        @error ||= current_intake.efile_submissions.last.last_transition.efile_errors.take
      end

      def reject_code
        # "USPS-2147219401"
        e_file_error.try(:code)
      end

      def reject_description
        # "Address Not Found."
        e_file_error.try(:message)
      end
    end
  end
end
