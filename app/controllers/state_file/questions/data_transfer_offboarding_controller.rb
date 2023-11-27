module StateFile
  module Questions
    class DataTransferOffboardingController < QuestionsController
      helper_method :ineligible_reason

      def ineligible_reason
        key = current_intake.disqualifying_eligibility_answer
        return key.present? ?
          I18n.t(
            "state_file.questions.eligibility_offboarding.edit.ineligible_reason.#{key}",
            state: States.name_for_key(params[:us_state].upcase)
          ) : nil
      end

      def self.show?(intake)
        intake.has_disqualifying_eligibility_answer?
      end
    end
  end
end
