module YearSelectionHelper
  def year_options_from_2014_to_current_tax_yr_plus_one
    (TaxReturn.current_tax_year + 1).downto(2014).map { |year| [year.to_s, year.to_s] } + [[t("general.before_2014"), "before 2014"]]
  end
end
