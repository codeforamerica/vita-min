module StateFile
  module Questions
    class VerificationCodeController < QuestionsController
      def edit
        case current_intake.contact_preference
        when "text"
          RequestVerificationCodeTextMessageJob.perform_later(
            phone_number: current_intake.phone_number,
            locale: I18n.locale,
            visitor_id: current_intake.visitor_id,
            client_id: nil,
            service_type: :statefile
          )
          @contact_info = PhoneParser.formatted_phone_number(current_intake.phone_number)
        when "email"
          RequestVerificationCodeEmailJob.perform_later(
            email_address: current_intake.email_address,
            locale: I18n.locale,
            visitor_id: current_intake.visitor_id,
            client_id: nil,
            service_type: :statefile
          )
          @contact_info = current_intake.email_address
        end
        super
      end
    end
  end
end