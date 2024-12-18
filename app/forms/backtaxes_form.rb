class BacktaxesForm < QuestionsForm
  set_attributes_for :intake, :needs_help_previous_year_3, :needs_help_previous_year_2, :needs_help_previous_year_1, :needs_help_current_year
  validate :at_least_one_year

  def save
    # some of the needs_help fields are not shown, based on what years the client has filed
    # but the intake does not allow nil values
    needs_help_params = {
      needs_help_previous_year_3: needs_help_previous_year_3.nil? ? "unfilled" : needs_help_previous_year_3,
      needs_help_previous_year_2: needs_help_previous_year_2.nil? ? "unfilled" : needs_help_previous_year_2,
      needs_help_previous_year_1: needs_help_previous_year_1.nil? ? "unfilled" : needs_help_previous_year_1,
      needs_help_current_year: needs_help_current_year.nil? ? "unfilled" : needs_help_current_year
    }
    @intake.update(attributes_for(:intake).merge(needs_help_params))

    data = MixpanelService.data_from([@intake.client, @intake])
    MixpanelService.send_event(
      distinct_id: @intake.visitor_id,
      event_name: "intake_started",
      data: data
    )
  end

  private

  def at_least_one_year
    chose_one = needs_help_previous_year_3 == "yes" ||
      needs_help_previous_year_2 == "yes" ||
      needs_help_previous_year_1 == "yes" ||
      needs_help_current_year == "yes"
    errors.add(:needs_help_current_year, I18n.t("forms.errors.at_least_one_year")) unless chose_one
  end
end
