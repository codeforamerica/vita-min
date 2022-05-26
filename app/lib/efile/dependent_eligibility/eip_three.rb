module Efile
  module DependentEligibility
    class EipThree < Efile::DependentEligibility::Base
      def initialize(*args, child_eligibility: nil, relative_eligibility: nil)
        @child_eligibility = child_eligibility
        @relative_eligibility = relative_eligibility
        super(*args)
      end

      def self.rules
        {
            qualifying_relationship_test: [:is_qualifying_child?, :is_qualifying_relative?],
            puerto_rico_test: [:not_puerto_rican_filing?]
        }
      end

      def benefit_amount
        qualifies? ? 1400 : 0
      end

      def not_puerto_rican_filing?
        !dependent.intake.puerto_rico_filing?
      end

      def is_qualifying_child?
        return dependent.qualifying_child if dependent.is_a? EfileSubmissionDependent

        (@child_eligibility || Efile::DependentEligibility::QualifyingChild.new(dependent, tax_year)).qualifies?
      end

      def is_qualifying_relative?
        (@relative_eligibility || Efile::DependentEligibility::QualifyingRelative.new(dependent, tax_year)).qualifies?
      end
    end
  end
end
