module Efile
  module DependentEligibility
    class QualifyingChild < Efile::DependentEligibility::Base
      # Keys with multiple conditions must be OR conditions, as only one must pass to remain eligible
      def self.rules
        {
            # Ctc::Questions::Dependents::Info
            relationship_test: :qualifying_child_relationship?,
            married_filing_joint_test: [
              :filed_joint_return_no?,
              :filed_joint_return_unfilled?
            ],
            tin_test: :ssn?,
            birth_test: :alive_during_tax_year?,
            # Ctc::Questions::Dependents::ChildQualifiers
            age_test: [
              :under_qualifying_age_limit?,
              :permanently_totally_disabled_yes?,
              :qualified_student?
            ],
            # Ctc::Questions::Dependents::ChildExpensesController
            financial_support_test: :provided_over_half_own_support_no?,
            # Ctc::Questions::Dependents::ChildLivedWithYouController, Ctc::Questions::Dependents::ChildResidenceExceptionsController
            residence_test: [
              :born_in_final_six_months?,
              :lived_with_more_than_six_months_yes?,
              :residence_exception_born_yes?, # 2020 question
              :residence_exception_passed_away_yes?, # 2020 question
              :residence_exception_adoption_yes?, # 2020 question
              :permanent_residence_with_client_yes? # in 2021, exception logic is consolidated into this question answer
            ],
            claimable_test: [
                :cant_be_claimed_by_other_yes?,
                :claim_anyway_yes?
            ]
        }
      end

      def qualified_student?
        age < 24 && dependent.full_time_student_yes?
      end

      def over_qualifying_age_limit?
        return age >= 17 if tax_year == 2020

        age >= 18
      end

      def under_qualifying_age_limit?
        !over_qualifying_age_limit?
      end

      private

      def born_in_final_six_months?
        dependent.born_in_final_6_months_of_tax_year?(tax_year)
      end

      def qualified_student?
        age < 24 && dependent.full_time_student_yes?
      end
    end
  end
end
