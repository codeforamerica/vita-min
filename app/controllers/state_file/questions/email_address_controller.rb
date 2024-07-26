module StateFile
  module Questions
    class EmailAddressController < QuestionsController
      def self.show?(intake)
        intake.contact_preference == "email"
      end
    end
  end
end