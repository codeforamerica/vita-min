module StateFile
  module Questions
    class DeclinedTermsAndConditionsController < QuestionsController

      def self.show?(intake)
        intake.consented_to_terms_and_conditions_no? || intake.consented_to_sms_terms_no?
      end

      private

      def prev_path
        if current_intake.consented_to_sms_terms_yes?
          super
        else
          StateFile::Questions::SmsTermsController.to_path_helper
        end
      end
    end
  end
end
