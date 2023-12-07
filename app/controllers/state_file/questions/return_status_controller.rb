module StateFile
  module Questions
    class ReturnStatusController < AuthenticatedQuestionsController
      helper_method :return_status
      helper_method :title

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
        case current_intake.efile_submissions.last.current_state
        when 'accepted'
          'accepted'
        when 'rejected'
          'rejected'
        else
          'pending'
        end
      end
    end
  end
end
