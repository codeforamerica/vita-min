module StateFile
  module Questions
    class PhoneNumberSignUpController < EmailSignUpController

      def self.show?(intake)
        intake.contact_preference == "text"
      end

      private

      def send_verification_code
        RequestVerificationCodeTextMessageJob.perform_later(
          phone_number: @form.phone_number,
          locale: I18n.locale,
          visitor_id: current_intake.visitor_id,
          client_id: nil,
          service_type: :statefile
        )
      end

      def get_existing_intake(intake)
        search = intake.class.where.not(id: intake.id)
        search = search.where(phone_number: intake.phone_number)
        search.first
      end

    end
  end
end