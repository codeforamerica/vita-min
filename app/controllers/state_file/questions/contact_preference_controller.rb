module StateFile
  module Questions
    class ContactPreferenceController < QuestionsController
      def update
        current_intake.update(intake_params)
        redirect_to next_path
      end

      private
      def next_path
        case params['us_state']
        when 'az'
          az_questions_email_address_path
        when 'ny'
          ny_questions_email_address_path
        end
      end

      def intake_params
        params.permit(:locale)
      end
    end
  end
end