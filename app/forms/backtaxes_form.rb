class BacktaxesForm < QuestionsForm
  set_attributes_for :intake, :needs_help_2017, :needs_help_2018, :needs_help_2019, :needs_help_2020, :source, :referrer, :locale
  validate :at_least_one_year

  def save
    @intake.update(attributes_for(:intake).merge(client: Client.create!))
    @intake.filing_years.each do |year|
      TaxReturn.create!(year: year, client: @intake.client)
    end
  end

  private

  def at_least_one_year
    chose_one = needs_help_2017 == "yes" ||
      needs_help_2018 == "yes" ||
      needs_help_2019 == "yes" ||
      needs_help_2020 == "yes"
    errors.add(:needs_help_2017, I18n.t("forms.errors.at_least_one_year")) unless chose_one
  end
end
