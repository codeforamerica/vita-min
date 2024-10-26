module Efile
  module Nj
    module NjPropertyTaxEligibility
      INELIGIBLE = :ineligible
      INELIGIBLE_FOR_DEDUCTION = :ineligible_for_deduction
      NOT_INELIGIBLE = :not_ineligible

      class << self
        def determine_eligibility(intake)
          state_wages = Efile::Nj::NjStateWages.calculate_state_wages(intake)

          wage_minimum = if intake.filing_status == :married_filing_separately || intake.filing_status == :single
            10_000
          else
            20_000
          end

          return NOT_INELIGIBLE if state_wages > wage_minimum

          meets_exception = intake.direct_file_data.is_primary_blind? ||
                            intake.primary_disabled_yes? ||
                            Efile::Nj::NjSenior.is_over_65(intake.primary_birth_date)

          spouse_meets_exception = intake.filing_status == :married_filing_jointly &&
                              (
                                intake.direct_file_data.is_spouse_blind? ||
                                intake.spouse_disabled_yes? ||
                                Efile::Nj::NjSenior.is_over_65(intake.spouse_birth_date)
                              )

          return INELIGIBLE_FOR_DEDUCTION if meets_exception || spouse_meets_exception

          INELIGIBLE
        end
      end
    end
  end
end
