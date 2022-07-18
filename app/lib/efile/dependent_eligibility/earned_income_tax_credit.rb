module Efile
  module DependentEligibility
    class EarnedIncomeTaxCredit < Efile::DependentEligibility::Base
      def initialize(*args, child_eligibility: nil)
        @child_eligibility = child_eligibility
        super(*args)
      end

      # Keys with multiple conditions must be OR conditions, as only one must pass to remain eligible
      def self.rules
        {
            qc_test: :is_qualifying_child?,
            tin_test: :tin_type_ssn?,
        }
      end

      private

      def is_qualifying_child?
        (@child_eligibility || Efile::DependentEligibility::QualifyingChild.new(dependent, tax_year)).qualifies?
      end

      def prequalifying_attribute
        "qualifying_eitc"
      end
    end
  end
end
