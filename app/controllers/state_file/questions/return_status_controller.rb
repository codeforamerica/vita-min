module StateFile
  module Questions
    class ReturnStatusController < AuthenticatedQuestionsController
      helper_method :return_status
      helper_method :title

      def edit; end

      def title
        case return_status
        when 'accepted'
          'Your 2023 Arizona state tax return is accepted'
        when 'rejected'
          'Unfortunately, your 2023 Arizona state tax return was rejected'
        else
          'You have submitted your 2023 Arizona tax return, and it is still waiting to be accepted.'
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
