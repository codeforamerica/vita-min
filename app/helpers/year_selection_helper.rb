module YearSelectionHelper
  def year_options_from_2018_to_current_tax_yr_plus_one
    (MultiTenantService.new(:gyr).current_tax_year + 1).downto(2018).map { |year| [year.to_s, year.to_s] } + [[t("general.before_2018"), "before 2018"]]
  end
end
