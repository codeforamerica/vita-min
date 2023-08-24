class InitialTaxReturnsService < BaseService
  def initialize(intake:)
    @intake = intake
  end

  def create!
    create_year(MultiTenantService.new(:gyr).current_tax_year) if @intake.needs_help_current_year == "yes"
    create_year(MultiTenantService.new(:gyr).backtax_years[0]) if @intake.needs_help_previous_year_1 == "yes"
    create_year(MultiTenantService.new(:gyr).backtax_years[1]) if @intake.needs_help_previous_year_2 == "yes"
    create_year(MultiTenantService.new(:gyr).backtax_years[2]) if @intake.needs_help_previous_year_3 == "yes"
  end

  private

  def create_year(year)
    return if @intake.client.tax_returns.where(year: year).exists?

    @intake.client.tax_returns.create(year: year).advance_to(:intake_in_progress)
  end
end