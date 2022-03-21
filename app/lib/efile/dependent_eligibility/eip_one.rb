module Efile
  module DependentEligibility
    class EipOne < Efile::DependentEligibility::Base
      def initialize(*args, child_eligibility: nil)
        @child_eligibility = child_eligibility
        super(*args)
      end

      # Keys with multiple conditions must be OR conditions, as only one must pass to remain eligible
      def self.rules
        {
            tax_year_test: :tax_year_2020?,
            qc_test: :is_qualifying_child?,
            tin_test: [:tin_type_ssn?, :tin_type_atin?],
            age_test: :under_age_limit?
        }
      end

      def benefit_amount
        qualifies? ? 500 : 0
      end

      private

      def tax_year_2020?
        tax_year == 2020
      end

      def is_qualifying_child?
        (@child_eligibility || Efile::DependentEligibility::QualifyingChild.new(dependent, tax_year)).qualifies?
      end

      def under_age_limit?
        age < 17
      end
    end
  end
end
