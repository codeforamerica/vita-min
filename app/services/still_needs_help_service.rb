class StillNeedsHelpService
  def self.must_show_still_needs_help_flow?(client)
    client.triggered_still_needs_help_at.present?
  end

  def self.trigger_still_needs_help_flow(client)
    client.triggered_still_needs_help_at = Time.now
    client.tax_returns.where(current_state: may_need_help_statuses).each { |tr| tr.transition_to!(:file_not_filing) }
    client.save
    send_still_need_help_notification(client)
  end

  def self.send_still_need_help_notification(client)
    ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
      client: client,
      locale: client.intake.locale,
      message: AutomatedMessage::ClosingSoon,
      body_args: { end_of_docs_date: I18n.l(Rails.configuration.end_of_docs.to_date, format: :medium, locale: client.intake.locale),
                   end_of_in_progress_intake_date: I18n.l(Rails.configuration.end_of_in_progress_intake.to_date, format: :medium, locale: client.intake.locale) }
    )
  end

  def self.may_need_help_statuses
    %w[intake_info_requested intake_in_progress intake_greeter_info_requested intake_needs_doc_help]
  end

  def self.clients_who_still_may_need_help(intake_type: nil)
    query = Client.joins(:tax_returns, :intake)
    query = query.where(intakes: { type: intake_type }) if intake_type.present?
    query.where(tax_returns: { status: may_need_help_statuses })
  end
end
