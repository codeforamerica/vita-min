class ContactRecordPresenter
  attr_reader :contact_record

  def initialize(contact_record)
    @contact_record = contact_record
    if contact_record.respond_to?(:client) && contact_record.client.respond_to?(:intake)
      if contact_record.client.intake
        @intake = contact_record.client.intake
      else
        @intake = Archived::Intake2021.find_by(client: contact_record.client)
      end
    end
  end

  def display_author
    type = contact_record.contact_record_type
    if type.to_s.include?("incoming")
      @intake.preferred_name
    else
      if contact_record.user
        contact_record.user.name_with_role
      else
        "#{I18n.t("hub.messages.automated")} "
      end
    end
  end

  def message_heading
    case contact_record.contact_record_type
    when :incoming_text_message
      "#{I18n.t("hub.messages.from")} #{contact_record.from}"
    when :outgoing_text_message
      "#{I18n.t("hub.messages.to")} #{contact_record.to}"
    when :incoming_email
      "#{I18n.t("hub.messages.from")} #{contact_record.from}"
    when :outgoing_email
      "#{I18n.t("hub.messages.to")} #{contact_record.to}"
    when :incoming_portal_message
      I18n.t("hub.messages.portal_message")
    else
      contact_record.try(:heading)
    end
  end
end
