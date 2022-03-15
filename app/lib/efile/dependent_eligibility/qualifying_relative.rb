module Efile
  module DependentEligibility
    class QualifyingRelative < Efile::DependentEligibility::Base
      def rules
        {
            relationship_test: [
                :qualifying_relative_relationship?,
                :qualifying_child_relationship? # only run relative requirements after child requirements - can only be one.
            ],
            tin_test: :ssn?,
            # Questions::Ctc::Dependents::RelativeResidencyController
            residence_test: :residence_lived_with_all_year_yes?,
            # Questions::Dependents::RelativeExpensesController
            financial_support_test: :filer_provided_over_half_support_yes?,
            # Questions::Dependents::RelativeQualifiersController
            miscellaneous_requirements: [
                :meets_misc_qualifying_relative_requirements_yes?, # 2020 tax year question
                :below_qualifying_relative_income_requirement_yes?, # 2021, more specific
                :cant_be_claimed_by_other_yes? # 2021, more specific
            ]
        }
      end
    end
  end
end