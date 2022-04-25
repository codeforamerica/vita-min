class StandardDeduction
  attr_accessor :tax_year

  def initialize(tax_year:)
    @tax_year = tax_year
  end

  def standard_deduction(filing_status, **kwargs)
    return unless filing_status

    send("standard_deduction_#{tax_year}", filing_status, **kwargs)
  rescue NoMethodError
    raise NotImplementedError, "Standard deduction rule not implemented for #{tax_year}"
  end

  def self.for(tax_year:, filing_status:, **kwargs)
    obj = new(tax_year: tax_year)
    obj.standard_deduction(filing_status, **kwargs)
  end

  private

  def standard_deduction_2020(filing_status, **_ignored)
    case filing_status.to_sym
    when :married_filing_jointly, :qualifying_widow
      24800
    when :head_of_household
      18650
    when :single, :married_filing_separately
      12400
    end
  end

  def standard_deduction_2021(filing_status, primary_older_than_65: nil, spouse_older_than_65: nil)
    base =
      case filing_status.to_sym
      when :married_filing_jointly, :qualifying_widow
        25100
      when :head_of_household
        18800
      when :single, :married_filing_separately
        12550
      end

    older_than_65_addition =
      case filing_status.to_sym
      when :single, :head_of_household
        primary_older_than_65 ? 1700 : 0
      when :married_filing_separately
        primary_older_than_65 ? 1350 : 0
      when :married_filing_jointly, :qualifying_widow
        (primary_older_than_65 ? 1350 : 0) + (spouse_older_than_65 ? 1350 : 0)
      else
        0
      end

    base + older_than_65_addition
  end
end
