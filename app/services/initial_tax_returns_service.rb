class InitialTaxReturnsService < BaseService
  def initialize(intake:)
    @intake = intake
  end

  def create!
    preexisting_tax_years = @intake.client.tax_returns.pluck(:year)
    # TODO(TY2022): Add 2022
    current = MultiTenantService.new(:gyr).current_tax_year
    create_years = (MultiTenantService.new(:gyr).filing_years - [2022]).filter { |year| !preexisting_tax_years.include?(year) && @intake.send("needs_help_previous_year_#{current-year}") == "yes" }
    create_years.map { |year| @intake.client.tax_returns.create(year: year).advance_to(:intake_in_progress) }
  end
end