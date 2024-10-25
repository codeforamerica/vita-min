module StateFile
  module NjPropertyEligibilityHelper
    INELIGIBLE = :ineligible
    INELIGIBLE_FOR_DEDUCTION = :ineligible_for_deduction
    NOT_INELIGIBLE = :not_ineligible

    class << self
      def determine_eligibility(intake)
        state_wages = Efile::Nj::NjStateWages.calculate_state_wages(intake)

        wage_minimum = intake.filing_status == :married_filing_separately || intake.filing_status == :single
          ? 10_000
          : 20_000

        return NOT_INELIGIBLE if state_wages > wage_minimum

        if intake.direct_file_data.is_primary_blind? 
            || intake.direct_file_data.is_spouse_blind?
            || intake.primary_disabled_yes?
            || intake.spouse_disabled_yes?
            || Efile::Nj::NjStateWages.is_over_65(intake.primary_birth_date)
            || Efile::Nj::NjStateWages.is_over_65(intake.spouse_birth_date)

          return INELIGIBLE_FOR_DEDUCTION 
        end

        INELIGIBLE
      end
    end
  end
end
