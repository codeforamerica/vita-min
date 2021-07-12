class StandardDeduction
  attr_accessor :filing_status, :tax_year

  def initialize(tax_year:, filing_status:)
    @tax_year = tax_year
    @filing_status = filing_status.to_sym
  end

  def standard_deduction_2020
    case filing_status
    when :married_filing_jointly, :qualifying_widow
      24800
    when :head_of_household
      18650
    when :single, :married_filing_separately
      12400
    end
  end

  def standard_deduction
    send("standard_deduction_#{tax_year}")
  rescue NoMethodError
    raise NotImplementedError, "Standard deduction rule not implemented for #{tax_year}"
  end

  def self.for(*args)
    obj = new(*args)
    obj.standard_deduction
  end
end