module Efile
  module DependentEligibility
    class ChildTaxCredit < Efile::DependentEligibility::Base
      def initialize(*args, child_eligibility: nil)
        @child_eligibility = child_eligibility
        super(*args)
      end

      # Keys with multiple conditions must be OR conditions, as only one must pass to remain eligible
      def self.rules
        {
            qc_test: :is_qualifying_child?,
            tin_test: :tin_type_ssn?,
            age_test: :under_ctc_age_limit?,
        }
      end

      def benefit_amount
        return 0 if tax_year == 2020 # not refundable, claimed on 2021 taxes in full
        return 0 unless qualifies?

        age >= 6 ? 3000 : 3600
      end

      def under_ctc_age_limit?
        ctc_age_cutoff = tax_year == 2020 ? 17 : 18
        age < ctc_age_cutoff
      end

      private

      def is_qualifying_child?
        return dependent.qualifying_child if dependent.is_a? EfileSubmissionDependent

        (@child_eligibility || Efile::DependentEligibility::QualifyingChild.new(dependent, tax_year)).qualifies?
      end

      def prequalifying_attribute
        "qualifying_child"
      end
    end
  end
end
