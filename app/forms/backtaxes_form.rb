class BacktaxesForm < QuestionsForm
  set_attributes_for :intake, :needs_help_2017, :needs_help_2018, :needs_help_2019, :needs_help_2020, :source, :referrer, :locale, :visitor_id
  validate :at_least_one_year

  def save
    @intake.update(attributes_for(:intake).merge(client: Client.create!))
    TaxReturn.filing_years.each do |year|
      TaxReturn.create!(year: year, client: intake.client) if @intake.send("needs_help_#{year}") == "yes"
    end
    data = MixpanelService.data_from([@intake.client, @intake])

    MixpanelService.send_event(
      distinct_id: @intake.visitor_id,
      event_name: "intake_started",
      data: data
    )
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
