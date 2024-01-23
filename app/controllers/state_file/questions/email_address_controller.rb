module StateFile
  module Questions
    class EmailAddressController < QuestionsController
      def self.show?(intake)
        intake.contact_preference == "email"
      end

      def update
        existing_intake = get_existing_intake
        session[:state_file_intake] = existing_intake.to_global_id if existing_intake
        super
      end

      def get_existing_intake
        email_address = initialized_update_form.email_address
        form_class.where(email_address: email_address).first
      end
    end
  end
end