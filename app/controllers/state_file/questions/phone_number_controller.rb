module StateFile
  module Questions
    class PhoneNumberController < QuestionsController
      def self.show?(intake)
        intake.contact_preference == "text"
      end

      def update
        existing_intake = get_existing_intake
        session[:state_file_intake] = existing_intake.to_global_id if existing_intake
        super
      end

      def get_existing_intake
        phone_number = initialized_update_form.phone_number
        form_class.where(phone_number: phone_number).first
      end
    end
  end
end