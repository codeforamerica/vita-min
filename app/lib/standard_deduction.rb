class StandardDeduction
  attr_accessor :tax_year

  def initialize(tax_year:)
    @tax_year = tax_year
  end

  def standard_deduction_2020(filing_status: nil)
    case filing_status.to_sym
    when :married_filing_jointly, :qualifying_widow
      24800
    when :head_of_household
      18650
    when :single, :married_filing_separately
      12400
    end
  end

  def standard_deduction(filing_status)
    return unless filing_status
    send("standard_deduction_#{tax_year}", filing_status: filing_status)
  rescue NoMethodError
    raise NotImplementedError, "Standard deduction rule not implemented for #{tax_year}"
  end

  def self.for(tax_year:, filing_status:)
    obj = new(tax_year: tax_year)
    obj.standard_deduction(filing_status)
  end
end