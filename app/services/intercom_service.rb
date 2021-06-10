require 'intercom'

class IntercomService
  def self.create_intercom_message_from_email(incoming_email, inform_of_handoff: false)
    email_address = incoming_email.sender
    body = incoming_email.body
    contact_id_from_email = contact_id_from_email(email_address)
    contact_id = contact_id_from_email.present? ? contact_id_from_email : create_intercom_contact(incoming_email).id

    if contact_id_from_email.present? && most_recent_conversation(contact_id).present?
      reply_to_existing_intercom_thread(contact_id, body)
    else
      create_new_intercom_thread(contact_id, body)
      send_handoff_email(incoming_email.client) if inform_of_handoff
    end
  end

  def self.create_intercom_message_from_sms(incoming_sms, inform_of_handoff: false)
    phone_number = incoming_sms.from_phone_number
    body = incoming_sms.body
    contact_id_from_sms = contact_id_from_sms(phone_number)
    contact_id = contact_id_from_sms.present? ? contact_id_from_sms : create_intercom_contact(incoming_sms).id

    if contact_id_from_sms.present? && most_recent_conversation(contact_id).present?
      reply_to_existing_intercom_thread(contact_id, body)
    else
      create_new_intercom_thread(contact_id, body)
      send_handoff_sms(incoming_sms.client) if inform_of_handoff
    end
  end

  private

  def self.send_handoff_email(client)
    locale = client.intake.locale
    ClientMessagingService.send_system_email(client: client, body: I18n.t("messages.intercom_forwarding.email.body", locale: locale), subject:  I18n.t("messages.intercom_forwarding.email.subject", locale: locale))
  end

  def self.send_handoff_sms(client)
    ClientMessagingService.send_system_text_message(client: client, body: I18n.t("messages.intercom_forwarding.sms.body", locale: client.intake.locale))
  end

  def self.contact_id_from_email(email)
    contacts = intercom.contacts.search(
      "query": {
        "field": 'email',
        "operator": '=',
        "value": email
      }
    )
    contacts&.first&.id
  end

  def self.contact_id_from_sms(phone_number)
    contacts = intercom.contacts.search(
      "query": {
        "field": 'phone',
        "operator": '=',
        "value": phone_number
      }
    )
    contacts&.first&.id
  end

  def self.create_intercom_contact(incoming_message)
    intercom.contacts.create(intercom_contact_attr(incoming_message))
  end

  def self.intercom_contact_attr(incoming_message)
    attributes = {
      role: "contact"
    }

    if incoming_message.is_a?(IncomingTextMessage)
      attributes[:phone_number] = incoming_message.from_phone_number
    elsif incoming_message.is_a?(IncomingTextMessage)
      attributes[:email] = incoming_message.client&.intake&.email_address || incoming_message.sender
    end

    if incoming_message.client&.present?
      attributes[:client] = incoming_message.client.id
      attributes[:external_id] = incoming_message.client.id
    else
      attributes[:role] = "lead"
    end

    name = incoming_message&.client&.legal_name
    attributes[:name] = name if name&.present?

    attributes
  end

  def self.create_new_intercom_thread(contact_id, body)
    intercom.messages.create({ from: { type: "contact", id: contact_id }, body: body })
  end

  def self.reply_to_existing_intercom_thread(contact_id, body)
    intercom.conversations.reply_to_last(
      intercom_user_id: contact_id,
      type: 'user',
      message_type: 'comment',
      body: body
    )
  end

  def self.most_recent_conversation(contact_id)
    intercom.conversations.find_all(intercom_user_id: contact_id, type: 'user').first
  end

  def self.intercom
    @intercom ||= Intercom::Client.new(token: EnvironmentCredentials.dig(:intercom, :intercom_access_token))
  end
end