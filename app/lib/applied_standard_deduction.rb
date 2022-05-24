class AppliedStandardDeduction
  attr_accessor :tax_year

  def initialize(tax_return:)
    @tax_return = tax_return
    @tax_year = tax_return.year
    @filing_status = tax_return.filing_status
    @intake = tax_return.intake
  end

  def applied_standard_deduction
    return nil if @intake.home_location_puerto_rico?

    StandardDeductions.base_deductions(tax_year: @tax_year)[@filing_status] + additional_blind_standard_deduction + additional_older_than_65_standard_deduction
  end

  private

  def additional_older_than_65_standard_deduction
    deductions = StandardDeductions.older_than_65_deductions(tax_year: @tax_year)
    case @filing_status
    when "single", "head_of_household"
      return deductions[:single_filer] if primary_age_65_or_older?
    when "married_filing_jointly"
      return deductions[:primary_and_spouse] if primary_age_65_or_older? && spouse_age_65_or_older?
      return deductions[:primary_or_spouse] if primary_age_65_or_older? || spouse_age_65_or_older?
    end
    0
  end

  def additional_blind_standard_deduction
    deductions = StandardDeductions.blind_deductions(tax_year: @tax_year)
    case @filing_status
    when "single", "head_of_household"
      return deductions[:single_filer] if intake.was_blind_yes?
    when "married_filing_jointly"
      return deductions[:primary_and_spouse] if intake.was_blind_yes? && intake.spouse_was_blind_yes?
      return deductions[:primary_or_spouse] if intake.was_blind_yes? || intake.spouse_was_blind_yes?
    end
    0
  end
end
