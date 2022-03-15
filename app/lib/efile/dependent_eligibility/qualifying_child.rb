module Efile
  module DependentEligibility
    class QualifyingChild < Efile::DependentEligibility::Base
      AGE_LIMIT = 18

      # Keys with multiple conditions must be OR conditions, as only one must pass to remain eligible
      def self.rules
        {
            # Ctc::Dependents::Info
            relationship_test: :qualifying_child_relationship?,
            married_filing_joint_test: [
                :filed_joint_return_no?,
                :filed_joint_return_unfilled?
            ],
            tin_test: :ssn?,
            birth_test: :alive_during_tax_year?,
            # Ctc::Dependents::Qualifiers
            age_test: [
                :under_qualifying_age_limit?,
                :permanently_totally_disabled_yes?,
                :qualified_student?
            ],
            # Ctc::Dependents::Expenses
            financial_support_test: :provided_over_half_own_support_no?,
            # Ctc::Dependents::PermanentResidence
            residence_test: [
                :born_in_final_six_months?,
                :lived_with_more_than_six_months_yes?,
                :residence_exception_born_yes?,
                :residence_exception_passed_away_yes?,
                :residence_exception_adoption_yes?,
                :permanent_residence_with_client_yes?
            ],
            # Ctc::Dependents::Claim, Ctc::Dependents::ClaimAnyway
            claimable_test: [
                :cant_be_claimed_by_other_yes?,
                :claim_anyway_yes?
            ]
        }
      end

      def over_qualifying_age_limit?
        age > AGE_LIMIT
      end

      private

      def under_qualifying_age_limit?
        !over_qualifying_age_limit?
      end

      def born_in_final_six_months?
        dependent.born_in_final_6_months_of_tax_year?(tax_year)
      end

      def qualified_student?
        age < 24 && dependent.full_time_student_yes?
      end

      def alive_during_tax_year?
        !dependent.born_after_tax_year?(tax_year)
      end
    end
  end
end
