module StateFile
  module Questions
    class SmsTermsController < QuestionsController
      def self.show?(intake)
        intake.phone_number?
      end
    end
  end
end
