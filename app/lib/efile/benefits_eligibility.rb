module Efile
  class BenefitsEligibility
    attr_accessor :year, :eligible_filer_count, :dependents, :intake
    def initialize(tax_return:, dependents:)
      @eligible_filer_count = tax_return.rrc_eligible_filer_count
      @year = tax_return.year
      @intake = tax_return.intake
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

    def outstanding_ctc_amount
      [ctc_amount - advance_ctc_amount_received, 0].max
    end

    def advance_ctc_amount_received
      raise "advance_ctc_amount_received is not present on intake #{intake.id}" unless intake.advance_ctc_amount_received

      intake.advance_ctc_amount_received
    end

    # A quick calculation for ODC (Other Dependents Credit) which does not get paid out to our filers,
    # but is needed for the 8812 calculation.
    def odc_amount
      return 0 if year == 2020

      dependents.count { |d| !d.qualifying_ctc? && (d.qualifying_child? || d.qualifying_relative?) } * 500
    end
  end
end