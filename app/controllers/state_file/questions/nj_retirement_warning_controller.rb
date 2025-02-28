module StateFile
  module Questions
    class NjRetirementWarningController < QuestionsController
      include EligibilityOffboardingConcern

      def self.show?(intake)
        line_15 = intake.calculator.line_or_zero(:NJ1040_LINE_15)
        line_16a = intake.calculator.line_or_zero(:NJ1040_LINE_16A)
        retirement_helper(intake).show_retirement_income_warning?(line_15, line_16a) && Flipper.enabled?(:show_retirement_ui)
      end

      def self.retirement_helper(intake)
        @retirement_helper ||= Efile::Nj::NjRetirementIncomeHelper.new(intake)
      end
    end
  end
end
