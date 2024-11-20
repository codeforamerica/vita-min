module StateFile
  module Questions
    class EligibilityOffboardingController < QuestionsController
      include OtherOptionsLinksConcern
      before_action :set_prev_path, only: [:edit]
      helper_method :ineligible_reason

      before_action -> { @filing_year = Rails.configuration.statefile_current_tax_year }

      def ineligible_reason
        key = current_intake.disqualifying_eligibility_answer
        if key.present?
          I18n.t(
            "state_file.questions.eligibility_offboarding.edit.ineligible_reason.#{key}",
            state: current_state_name,
            filing_year: @filing_year
          )
        end
      end

      def set_prev_path
        @prev_path = session.delete(:offboarded_from)
      end

      def prev_path
        @prev_path || super
      end

      def self.show?(intake)
        intake.has_disqualifying_eligibility_answer?
      end
    end
  end
end