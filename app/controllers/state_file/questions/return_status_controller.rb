module StateFile
  module Questions
    class ReturnStatusController < AuthenticatedQuestionsController
      helper_method :return_status

      def edit; end

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
