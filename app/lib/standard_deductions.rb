class StandardDeductions
  def self.import(filename)
    @@standard_deductions = YAML.load_file(filename)['standard_deductions'].with_indifferent_access
  end

  def self.base_deductions(tax_year: TaxReturn.current_tax_year, puerto_rico_filing: false)
    puerto_rico_filing ? @@standard_deductions[:base_puerto_rico][tax_year] : @@standard_deductions[:base][tax_year]
  end

  def self.blind_deductions(tax_year: TaxReturn.current_tax_year)
    @@standard_deductions[:blind][tax_year]
  end

  def self.older_than_65_deductions(tax_year: TaxReturn.current_tax_year)
    @@standard_deductions[:older_than_65][tax_year]
  end
end
