module StateFile
  module Questions
    class EmailAddressController < AuthenticatedQuestionsController
      def self.show?(intake)
        intake.contact_preference == "email"
      end
    end
  end
end