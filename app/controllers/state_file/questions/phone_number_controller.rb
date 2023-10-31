module StateFile
  module Questions
    class PhoneNumberController < QuestionsController
      def self.show?(intake)
        intake.contact_preference == "text"
      end
    end
  end
end