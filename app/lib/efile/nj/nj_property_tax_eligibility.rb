module Efile
  module Nj
    module NjPropertyTaxEligibility
      INELIGIBLE = :ineligible
      POSSIBLY_ELIGIBLE_FOR_CREDIT = :possibly_eligible_for_credit
      POSSIBLY_ELIGIBLE_FOR_DEDUCTION_OR_CREDIT = :possibly_eligible_for_deduction_or_credit

      class << self
        def ineligible?(intake)
          determine_eligibility(intake) == INELIGIBLE
        end

        def possibly_eligible_for_credit?(intake)
          determine_eligibility(intake) == POSSIBLY_ELIGIBLE_FOR_CREDIT
        end

        def possibly_eligible_for_deduction_or_credit?(intake)
          determine_eligibility(intake) == POSSIBLY_ELIGIBLE_FOR_DEDUCTION_OR_CREDIT
        end

        def determine_eligibility(intake)
          total_income = intake.calculator.lines[:NJ1040_LINE_29].value

          wage_minimum = if intake.filing_status_mfs? || intake.filing_status_single?
                           10_000
                         else
                           20_000
                         end

          return POSSIBLY_ELIGIBLE_FOR_DEDUCTION_OR_CREDIT if total_income > wage_minimum

          meets_exception = intake.direct_file_data.is_primary_blind? ||
                            intake.primary_disabled_yes? ||
                            intake.primary_senior?

          spouse_meets_exception = intake.filing_status_mfj? &&
                                   (
                                     intake.direct_file_data.is_spouse_blind? ||
                                     intake.spouse_disabled_yes? ||
                                     intake.spouse_senior?
                                   )

          return POSSIBLY_ELIGIBLE_FOR_CREDIT if meets_exception || spouse_meets_exception

          INELIGIBLE
        end
      end
    end
  end
end
