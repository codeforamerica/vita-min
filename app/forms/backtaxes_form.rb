class BacktaxesForm < QuestionsForm
  set_attributes_for :intake, :needs_help_2018, :needs_help_2019, :needs_help_2020, :needs_help_2021, :source, :referrer, :locale, :visitor_id
  validate :at_least_one_year

  def save
    # some of the needs_help fields are not shown, based on what years the client has filed
    # but the intake does not allow nil values
    needs_help_params = {
      needs_help_2018: needs_help_2018.nil? ? "unfilled" : needs_help_2018,
      needs_help_2019: needs_help_2019.nil? ? "unfilled" : needs_help_2019,
      needs_help_2020: needs_help_2020.nil? ? "unfilled" : needs_help_2020,
      needs_help_2021: needs_help_2021.nil? ? "unfilled" : needs_help_2021
    }
    @intake.update(attributes_for(:intake).merge(client: Client.create!).merge(needs_help_params))

    data = MixpanelService.data_from([@intake.client, @intake])
    MixpanelService.send_event(
      distinct_id: @intake.visitor_id,
      event_name: "intake_started",
      data: data
    )
  end

  private

  def at_least_one_year
    chose_one = needs_help_2018 == "yes" ||
      needs_help_2019 == "yes" ||
      needs_help_2020 == "yes" ||
      needs_help_2021 == "yes"
    errors.add(:needs_help_2018, I18n.t("forms.errors.at_least_one_year")) unless chose_one
  end
end
