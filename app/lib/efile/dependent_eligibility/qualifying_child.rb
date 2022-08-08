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
            additional_puerto_rico_rules_test: [:additional_puerto_rico_rules?],
            primary_and_spouse_age_test: :younger_than_primary_and_spouse?,
            # Ctc::Questions::Dependents::ChildExpensesController
            financial_support_test: :provided_over_half_own_support_no?,
            # Ctc::Questions::Dependents::ChildResidenceController, Ctc::Questions::Dependents::ChildResidenceExceptionsController
            residence_test: [
              :born_in_final_six_months?,
              :months_in_home_more_than_6?,
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
        age > 18
      end

      def born_in_final_six_months?
        dependent.born_in_final_6_months_of_tax_year?(tax_year)
      end

      def under_qualifying_age_limit?
        !over_qualifying_age_limit?
      end

      def additional_puerto_rico_rules?
        return true unless dependent.intake.home_location_puerto_rico?

        return false if dependent.tin_type_ssn_no_employment?

        return false if dependent.tin_type_atin?

        dependent.birth_date > Date.new(2004, 1, 1)
      end

      def younger_than_primary_and_spouse?
        younger_than_primary = dependent.birth_date > dependent.intake.primary_birth_date

        if dependent.intake.filing_jointly?
          younger_than_primary && dependent.birth_date > dependent.intake.spouse_birth_date
        else
          younger_than_primary
        end
      end

      private

      def prequalifying_attribute
        "qualifying_child"
      end
    end
  end
end
