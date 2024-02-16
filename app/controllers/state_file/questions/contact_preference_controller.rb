module StateFile
  module Questions
    class ContactPreferenceController < QuestionsController
=begin
      def update
        # current_intake.update(permitted_params)
        binding.pry
        current_intake.update(intake_params)
        redirect_to next_path
      end

      private
      def next_path
        case params['us_state']
        when 'az'
          case current_intake.contact_preference
          when 'text'
            az_questions_phone_number_path
          else # 'email'
            az_questions_email_address_path
          end
        else # 'ny'
          case current_intake.contact_preference
          when 'text_message'
            ny_questions_phone_number_path
          else
            ny_questions_email_address_path
          end
        end
      end

      def intake_params
        params.permit(:locale)
      end
=end

=begin
      def state_file_contact_preference_params
        params.require(:state_file_contact_preference_form).permit(:contact_preference)
      end

      def permitted_params
        intake_params.merge(state_file_contact_preference_params)
      end
=end
    end
  end
end