module ContactRecordHelper
  def message_heading(contact_record)
    type = contact_record.contact_record_type
    heading = ""
    heading = "#{I18n.t("hub.messages.automated")} " if type.to_s.include?("outgoing") && contact_record.user.blank?
    heading +=  case type
                when :incoming_text_message
                  "#{I18n.t("hub.messages.text_from")} #{contact_record.from}"
                when :outgoing_text_message
                  "#{I18n.t("hub.messages.text_to")} #{contact_record.to}"
                when :incoming_email
                  "#{I18n.t("hub.messages.email_from")} #{contact_record.from}"
                when :outgoing_email
                  "#{I18n.t("hub.messages.email_to")} #{contact_record.to}"
                else
                  ""
                end
    heading
  end
end