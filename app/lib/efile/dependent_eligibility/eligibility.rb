module Efile
  module DependentEligibility
    class Eligibility < Efile::DependentEligibility::Base
      attr_accessor :dependent, :tax_year

      def self.rules
        {
          qualifying_child: :qualifying_child?,
          qualifying_relative: :qualifying_relative?,
          qualifying_ctc: :qualifying_ctc?,
          qualifying_eip3: :qualifying_eip3?,
          qualifying_eip2: :qualifying_eip2?,
          qualifying_eip1: :qualifying_eip1?,
        }
      end

      def benefit_amounts
        {
            eip1: eip_one_eligibility.benefit_amount,
            eip2: eip_two_eligibility.benefit_amount,
            eip3: eip_three_eligibility.benefit_amount,
            ctc: ctc_eligibility.benefit_amount
        }
      end

      def qualifying_child?
        @qualifying_child ||= child_eligibility.qualifies?
      end

      def qualifying_relative?
        @qualifying_relative ||= !child_eligibility.qualifies? && relative_eligibility.qualifies?
      end

      def qualifying_ctc?
        @qualifying_ctc ||= ctc_eligibility.qualifies?
      end

      def qualifying_eip3?
        @qualifying_eip3 ||=eip_three_eligibility.qualifies?
      end

      def qualifying_eip2?
        @qualifying_eip2 ||= eip_one_eligibility.qualifies?
      end

      def qualifying_eip1?
        @qualifying_eip1 ||= eip_one_eligibility.qualifies?
      end

      def total_benefit_amount
        @total_benefit_amount ||= benefit_amounts.values.sum
      end

      def relative_eligibility
        @relative_eligibility ||= Efile::DependentEligibility::QualifyingRelative.new(dependent, tax_year)
      end

      def child_eligibility
        @child_eligibility ||= Efile::DependentEligibility::QualifyingChild.new(dependent, tax_year)
      end

      def ctc_eligibility
        @ctc_eligibility ||= Efile::DependentEligibility::ChildTaxCredit.new(dependent, tax_year, child_eligibility: child_eligibility)
      end

      def eip_one_eligibility
        @eip_one_eligibility ||= Efile::DependentEligibility::EipOne.new(dependent, tax_year, child_eligibility: child_eligibility)
      end

      def eip_two_eligibility
        @eip_two_eligibility ||= Efile::DependentEligibility::EipTwo.new(dependent, tax_year, child_eligibility: child_eligibility)
      end

      def eip_three_eligibility
        @eip_three_eligibility ||= Efile::DependentEligibility::EipThree.new(dependent, tax_year, child_eligibility: child_eligibility, relative_eligibility: relative_eligibility)
      end
    end
  end
end