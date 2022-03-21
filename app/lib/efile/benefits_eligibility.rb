module Efile
  class BenefitsEligibility
    attr_accessor :year, :eligible_filer_count, :dependents
    def initialize(tax_return:, dependents:)
      @eligible_filer_count = tax_return.rrc_eligible_filer_count
      @year = tax_return.year
      @dependents = dependents
    end

    def eip1_amount
      return 0 unless year == 2020

      sum = 1200 * eligible_filer_count
      sum += dependents.map { |d| Efile::DependentEligibility::EipOne.new(d, year).benefit_amount }.sum
      sum
    end

    def eip2_amount
      return 0 unless year == 2020

      sum = 600 * eligible_filer_count
      sum += dependents.map { |d| Efile::DependentEligibility::EipTwo.new(d, year).benefit_amount }.sum
      sum
    end

    def eip3_amount
      sum = 1400 * eligible_filer_count
      sum += dependents.map { |d| Efile::DependentEligibility::EipThree.new(d, year).benefit_amount }.sum
      sum
    end

    def ctc_amount
      return 0 if year == 2020

      dependents.map { |d| Efile::DependentEligibility::ChildTaxCredit.new(d, year).benefit_amount }.sum
    end
  end
end