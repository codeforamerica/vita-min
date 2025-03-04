module StateFile
  module Questions
    class NjRetirementWarningController < QuestionsController
      include EligibilityOffboardingConcern


      def self.show?(intake)
        show_retirement_income_warning?(intake)
      end

      private

      def show_retirement_income_warning?(intake)
        line_15 = intake.calculator.line_or_zero(:NJ1040_LINE_15)
        line_16a = intake.calculator.line_or_zero(:NJ1040_LINE_16A)

        if intake.non_military_1099r_box_1_total.zero?
          return false
        end

        box_1_gross_income = non_military_1099r_box_1_total + line_15 + line_16a
        max_exclusion_threshold = if intake.filing_status_mfs?
                                    50_000
                                  elsif intake.filing_status_mfj?
                                    100_000
                                  else
                                    75_000
                                  end
        if box_1_gross_income <= max_exclusion_threshold
          return false
        end

        if non_military_1099r_box_1_total <= max_exclusion_threshold && (line_15 > 3_000 || all_filers_under_62?)
          return false
        end

        true
      end

      def non_military_1099r_box_1_total
        intake.non_military_1099rs.sum { |non_military_1099r| non_military_1099r.gross_distribution_amount.round }
      end
    end
  end
end
