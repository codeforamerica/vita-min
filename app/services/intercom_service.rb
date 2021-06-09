require 'intercom'

class IntercomService
  def self.create_intercom_message_from_email(incoming_email)
    email = incoming_email.client&.intake&.email_address || incoming_email.sender
    body = incoming_email.body
    contact_id_from_email = contact_id_from_email(email)
    contact_id = contact_id_from_email.present? ? contact_id_from_email : create_intercom_contact(incoming_email).id

    if contact_id_from_email.present? && most_recent_conversation(contact_id).present?
      reply_to_existing_intercom_thread(contact_id, body)
    else
      create_new_intercom_thread(contact_id, body)
    end
  end

  def self.create_intercom_message_from_sms(incoming_sms)
    phone_number = incoming_sms.from_phone_number
    body = incoming_sms.body
    contact_id_from_sms = contact_id_from_sms(phone_number)
    contact_id = contact_id_from_sms.present? ? contact_id_from_sms : create_intercom_contact(incoming_sms).id

    if contact_id_from_sms.present? && most_recent_conversation(contact_id).present?
      reply_to_existing_intercom_thread(contact_id, body)
    else
      create_new_intercom_thread(contact_id, body)
    end
  end

  private

  def contact_id_from_email(email)
    contacts = intercom.contacts.search(
      "query": {
        "field": 'email',
        "operator": '=',
        "value": email
      }
    )
    contacts&.first&.id
  end

  def contact_id_from_sms(phone_number)
    contacts = intercom.contacts.search(
      "query": {
        "field": 'phone',
        "operator": '=',
        "value": phone_number
      }
    )
    contacts&.first&.id
  end

  def create_intercom_contact(incoming_message)
    intercom.contacts.create(intercom_contact_attr(incoming_message))
  end

  def intercom_contact_attr(incoming_message)
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

  def create_new_intercom_thread(contact_id, body)
    intercom.messages.create({ from: { type: "contact", id: contact_id }, body: body })
  end

  def reply_to_existing_intercom_thread(contact_id, body)
    intercom.conversations.reply_to_last(
      intercom_user_id: contact_id,
      type: 'user',
      message_type: 'comment',
      body: body
    )
  end

  def most_recent_conversation(contact_id)
    intercom.conversations.find_all(intercom_user_id: contact_id, type: 'user').first
  end

  def intercom
    # @intercom ||= Intercom::Client.new(token: EnvironmentCredentials.dig(:intercom, :intercom_access_token)) #need to add access token
    @intercom = Intercom::Client.new(token: "dG9rOjNmYmU5NzhiXzBmMGRfNDc2Zl85NTU1XzRmMDdjODI5Yjg5MzoxOjA=")
  end
end