module ContactRecordHelper
  def twilio_deliverability_status(status)
    status ||= "sending"

    icon = "icons/waiting.svg"
    icon = "icons/exclamation.svg" if OutgoingTextMessage::FAILED_TWILIO_STATUSES.include?(status)
    icon = "icons/check.svg" if OutgoingTextMessage::SUCCESSFUL_TWILIO_STATUSES.include?(status)
    image_tag(icon, alt: status, title: status, class: 'message__status')
  end

  def mailgun_deliverability_status(status)
    return unless status.present?

    icon = "icons/waiting.svg"
    icon = "icons/exclamation.svg" if OutgoingEmail::FAILED_MAILGUN_STATUSES.include?(status)
    icon = "icons/check.svg" if OutgoingEmail::SUCCESSFUL_MAILGUN_STATUSES.include?(status)
    image_tag(icon, alt: status, title: status, class: 'message__status')
  end

  def client_contact_preference(client, no_tags: false)
    contact_methods = ClientMessagingService.contact_methods(client)
    methods = contact_methods.keys&.map { |k| I18n.t("general.contact_methods.#{k}") }&.join("/")
    contacts = contact_methods.values&.join(" or ")
    message = I18n.t("portal.messages.new.contact_preference", contact_info: contacts, contact_method: methods)
    no_tags ? message : content_tag(:span, message)
  end
end
