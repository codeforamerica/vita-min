module Efile
  module DependentEligibility
    class QualifyingRelative < Efile::DependentEligibility::Base
      def self.rules
        {
            # Ctc::Questions::Dependents::Info
            birth_test: :alive_during_tax_year?,
            married_filing_joint_test: [
                :filed_joint_return_no?,
                :filed_joint_return_unfilled?
            ],
            relationship_test: [
                :qualifying_relative_relationship?,
                :qualifying_child_relationship?
            ],
            tin_test: :ssn?,
            # Ctc::Questions::Dependents::ChildExpensesController
            is_supported_test: [
                :provided_over_half_own_support_no?,
                :provided_over_half_own_support_unfilled? # allows for fall-through of failing QC age to QR flow
            ],
            # Questions::Ctc::Dependents::RelativeMemberOfHouseholdController
            residence_test: :is_member_of_household_if_required?,
            # Questions::Dependents::RelativeExpensesController
            financial_support_test: :filer_financially_supported?,
            # Questions::Dependents::RelativeQualifiersController
            claimable_test: [
              :meets_misc_qualifying_relative_requirements_yes?, # 2020 tax year question
              :cant_be_claimed_by_other_and_below_income_requirement? # 2021
            ]
        }
      end

      def requires_member_of_household_test?
        dependent.relationship_info.qualifying_relative_requires_member_of_household_test?
      end

      private

      def filer_financially_supported?
        # this is not defined or required on archived dependents
        return true if tax_year == 2020

        dependent.filer_provided_over_half_support_yes?
      end

      # These questions are grouped into one rule so that we can be backwards compatible with 2020 eligibility,
      # which stored the answers to both questions in one attribute called meets_misc_qualifying_relative_requirements
      def cant_be_claimed_by_other_and_below_income_requirement?
        dependent.cant_be_claimed_by_other_yes? && dependent.below_qualifying_relative_income_requirement_yes?
      end

      # Most relationships are considered a "member of the household" without needing to live in the household all year
      # For other relationships, 12 months living in household is required to be a member of the household
      def is_member_of_household_if_required?
        return true unless requires_member_of_household_test?

        requires_member_of_household_test? && dependent.residence_lived_with_all_year_yes?
      end
    end
  end
end