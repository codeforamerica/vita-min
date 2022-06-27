require 'intercom'

class IntercomService
  def self.create_intercom_message_from_portal_message(portal_message, inform_of_handoff: false)
    client = portal_message.client
    create_intercom_message(
      client: client,
      body: portal_message.body,
      inform_of_handoff: inform_of_handoff,
      email_address: client.intake.email_address,
      phone_number: client.intake.sms_phone_number
    )
  end

  def self.create_intercom_message_from_email(incoming_email, inform_of_handoff: false)
    create_intercom_message(
      client: incoming_email.client,
      inform_of_handoff: inform_of_handoff,
      body: incoming_email.body,
      email_address: incoming_email.sender
    )
  end

  def self.create_intercom_message_from_sms(incoming_sms, inform_of_handoff: false)
    create_intercom_message(
      phone_number: incoming_sms.from_phone_number,
      body: incoming_sms.body,
      client: incoming_sms.client,
      inform_of_handoff: inform_of_handoff,
      documents: incoming_sms.documents
    )
  end

  def self.create_intercom_message(email_address: nil, phone_number: nil, body: nil, client: nil, documents: [], inform_of_handoff: false)
    message_body = body
    if documents.present? && client.present?
      message_body = [body, "[client sent an attachment, see #{Rails.application.routes.url_helpers.hub_client_documents_url(client_id: client.id)}]"].compact.join(' ')
    end
    return nil if message_body.blank?

    existing_contact = contact_from_client(client) || contact_from_email(email_address) || contact_from_sms(phone_number)

    if existing_contact.present? && most_recent_conversation(existing_contact.id).present?
      reply_to_existing_intercom_thread(existing_contact.id, body)
    else
      contact = existing_contact || create_or_update_intercom_contact(client: client, email_address: email_address, phone_number: phone_number)

      create_new_intercom_thread(contact&.id, message_body)
      if inform_of_handoff && client.present?
        SendAutomatedMessage.send_messages(
          message: AutomatedMessage::IntercomForwarding,
          sms: phone_number.present?,
          email: email_address.present?,
          client: client
        )
      end
    end
  end

  private

  def self.contact_from_email(email)
    return unless email.present?

    contacts = intercom.contacts.search(
      "query": {
        "field": 'email',
        "operator": '=',
        "value": email
      }
    )
    contacts&.first
  end

  def self.contact_from_sms(phone_number)
    return unless phone_number.present?

    contacts = intercom.contacts.search(
      "query": {
        "field": 'phone',
        "operator": '=',
        "value": phone_number
      }
    )
    contacts&.first
  end

  def self.contact_from_client(client)
    return unless client.present?

    contacts = intercom.contacts.search(
      "query": {
        "field": 'external_id',
        "operator": '=',
        "value": client.id&.to_s
      }
    )
    contacts&.first
  end

  def self.create_or_update_intercom_contact(client: nil, phone_number: nil, email_address: nil)
    intercom_contact = contact_from_client(client) || contact_from_email(email_address) || contact_from_sms(phone_number)

    if intercom_contact.present?
      update_intercom_contact(intercom_contact, phone_number: phone_number, email_address: email_address)
    else
      begin
        intercom.contacts.create(intercom_contact_attributes(client: client, phone_number: phone_number, email_address: email_address))
      rescue Intercom::MultipleMatchingUsersError => e
        intercom_contact_id = e.message.match(/id=(\S+)/)[1]
        update_intercom_contact(intercom_contact_id, phone_number: phone_number, email_address: email_address)
      end
    end
  end

  def self.update_intercom_contact(contact, client: nil, phone_number: nil, email_address: nil)
    contact.from_hash(intercom_contact_attributes(client: client, phone_number: phone_number, email_address: email_address))
    intercom.contacts.save(contact)
    contact
  end

  def self.intercom_contact_attributes(phone_number: nil, email_address: nil, client: nil)
    attributes = {
      role: client.present? ? "contact" : "lead",
    }
    attributes[:phone] = phone_number if phone_number.present?
    attributes[:email] = email_address if email_address.present?

    attributes[:external_id] = client.id.to_s if client.present?
    attributes[:client] = client.id.to_s if client.present?
    attributes[:name] = client&.legal_name if client.present?
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