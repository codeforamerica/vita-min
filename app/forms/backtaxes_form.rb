class BacktaxesForm < QuestionsForm
  set_attributes_for :intake, :needs_help_2017, :needs_help_2018, :needs_help_2019, :source, :referrer, :locale
  validate :at_least_one_year

  def save
    @intake.update(attributes_for(:intake).merge(client: client))
  end

  private

  def client
    @intake.client || Client.create!
  end

  def at_least_one_year
    chose_one = needs_help_2017 == "yes" ||
      needs_help_2018 == "yes" ||
      needs_help_2019 == "yes"
    errors.add(:needs_help_2017, I18n.t("forms.errors.at_least_one_year")) unless chose_one
  end
end
