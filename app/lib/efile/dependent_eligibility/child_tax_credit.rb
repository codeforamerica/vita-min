module Efile
  module DependentEligibility
    class ChildTaxCredit < Efile::DependentEligibility::Base
      # Keys with multiple conditions must be OR conditions, as only one must pass to remain eligible
      def self.rules
        {
            qc_test: :qualifying_child?,
            tin_test: :ssn?,
            age_test: :under_ctc_age_limit?,
        }
      end


      private

      def qualifying_child?
        Efile::DependentEligibility::QualifyingChild.new(self, tax_year).qualifies?
      end

      def under_ctc_age_limit?
        ctc_age_cutoff = tax_year == 2020 ? 17 : 18
        age < ctc_age_cutoff
      end
    end
  end
end
