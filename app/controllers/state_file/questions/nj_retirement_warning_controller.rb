module StateFile
  module Questions
    class NjRetirementWarningController < QuestionsController
      include EligibilityOffboardingConcern

      def self.show?(intake)
        line_15 = intake.calculator.line_or_zero(:NJ1040_LINE_15)
        line_16a = intake.calculator.line_or_zero(:NJ1040_LINE_16A)
        retirement_helper = Efile::Nj::NjRetirementIncomeHelper.new(intake)
        should_show = retirement_helper.show_retirement_income_warning?(line_15, line_16a) && Flipper.enabled?(:show_retirement_ui)
        if should_show && intake.eligibility_retirement_warning_continue_unfilled?
          intake.eligibility_retirement_warning_continue = :shown
        end
        should_show
      end
    end
  end
end
