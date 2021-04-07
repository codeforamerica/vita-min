module ContactRecordHelper
  def display_author(contact_record)
    type = contact_record.contact_record_type
    return "#{I18n.t("hub.messages.automated")} " if type.to_s.include?("outgoing") && !contact_record.try(:author)

    contact_record.try(:author)
  end

  def message_heading(contact_record)
    case contact_record.contact_record_type
    when :incoming_text_message
      "#{I18n.t("hub.messages.from")} #{contact_record.from}"
    when :outgoing_text_message
      "#{I18n.t("hub.messages.to")} #{contact_record.to}"
    when :incoming_email
      "#{I18n.t("hub.messages.from")} #{contact_record.from}"
    when :outgoing_email
      "#{I18n.t("hub.messages.to")} #{contact_record.to}"
    else
      contact_record.try(:heading)
    end
  end

  def twilio_deliverability_status(status)
    status ||= "sending"
    sent_statuses = %w[sent delivered]
    failed_statuses = %w[undelivered failed delivery_unknown]
    icon = "icons/waiting.svg"
    icon = "icons/exclamation.svg" if failed_statuses.include?(status)
    icon = "icons/check.svg" if sent_statuses.include?(status)
    image_tag(icon, alt: status, title: status, class: 'message__status')
  end

  def mailgun_deliverability_status(message)
    return unless message.mailgun_id.present?

    status = message.mailgun_status || "sending"
    sent_statuses = %w[delivered]
    failed_statuses = %w[failed]
    icon = "icons/waiting.svg"
    icon = "icons/exclamation.svg" if failed_statuses.include?(status)
    icon = "icons/check.svg" if sent_statuses.include?(status)
    image_tag(icon, alt: status, title: status, class: 'message__status')
  end
end