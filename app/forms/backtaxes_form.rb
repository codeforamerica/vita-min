class BacktaxesForm < QuestionsForm
  set_attributes_for :intake, :needs_help_2016, :needs_help_2017, :needs_help_2018, :needs_help_2019
  validate :at_least_one_year

  def save
    @intake.update(attributes_for(:intake))
  end

  private

  def at_least_one_year
    chose_one = needs_help_2016 == "yes" ||
      needs_help_2017 == "yes" ||
      needs_help_2018 == "yes" ||
      needs_help_2019 == "yes"
    errors.add(:needs_help_2016, I18n.t("forms.errors.at_least_one_year")) unless chose_one
  end
end