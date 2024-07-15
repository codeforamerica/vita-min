module StateFile
  module Questions
    class PhoneNumberController < AuthenticatedQuestionsController
      def self.show?(intake)
        intake.contact_preference == "text"
      end
    end
  end
end