module StateFile
  module Questions
    class VerificationCodeController < QuestionsController
      def edit
        case current_intake.contact_preference
        when "text"
          @contact_method = PhoneParser.formatted_phone_number(current_intake.phone_number)
        when "email"
          @contact_method = current_intake.email_address
        end

        super
      end
    end
  end
end