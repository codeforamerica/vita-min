require 'intercom'

class IntercomService
  def self.create_message(email_address:, phone_number:, body:, client:, has_documents:)
    if has_documents && client.present?
      body = [body, "[client sent an attachment, see #{Rails.application.routes.url_helpers.hub_client_documents_url(client_id: client.id)}]"].compact.join(' ')
    end
    return nil if body.blank?

    contact = contact_from_client(client) || contact_from_email(email_address) || contact_from_sms(phone_number)

    if contact.present? && most_recent_conversation(contact.id).present?
      # Per https://developers.intercom.com/intercom-api-reference/reference/reply-to-a-conversation
      # type is always user and message_type is always comment.
      intercom.conversations.reply(
        id: 'last',
        intercom_user_id: contact.id,
        type: 'user',
        message_type: 'comment',
        body: body
      )
    else
      contact ||= create_intercom_contact(client: client, email_address: email_address, phone_number: phone_number)

      create_new_intercom_thread(contact, body)
    end
  end

  def self.inform_client_of_handoff(client:, send_sms:, send_email:)
    # TODO: add spec
    return if client.blank?

    SendAutomatedMessage.send_messages(
      message: AutomatedMessage::IntercomForwarding,
      sms: send_sms,
      email: send_email,
      client: client
    )
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

  def self.create_intercom_contact(client:, phone_number:, email_address:)
    begin
      intercom.contacts.create(intercom_contact_attributes(client: client, phone_number: phone_number, email_address: email_address))
    rescue Intercom::MultipleMatchingUsersError => e
      # TODO: Test this case
      intercom_contact_id = e.message.match(/id=(\S+)/)[1]
      update_intercom_contact(intercom_contact_id, client: client, phone_number: phone_number, email_address: email_address)
    end
  end


  def self.create_or_update_intercom_contact(client:, phone_number:, email_address:)
    intercom_contact = contact_from_client(client) || contact_from_email(email_address) || contact_from_sms(phone_number)

    if intercom_contact.present?
      update_intercom_contact(intercom_contact, client: client, phone_number: phone_number, email_address: email_address)
    else
      begin
        intercom.contacts.create(intercom_contact_attributes(client: client, phone_number: phone_number, email_address: email_address))
      rescue Intercom::MultipleMatchingUsersError => e
        # TODO: Test this case
        intercom_contact_id = e.message.match(/id=(\S+)/)[1]
        update_intercom_contact(intercom_contact_id, client: client, phone_number: phone_number, email_address: email_address)
      end
    end
  end

  def self.update_intercom_contact(contact, client:, phone_number:, email_address:)
    contact.from_hash(intercom_contact_attributes(client: client, phone_number: phone_number, email_address: email_address))
    intercom.contacts.save(contact)
    contact
  end

  def self.intercom_contact_attributes(phone_number:, email_address:, client:)
    attributes = {
      role: client.present? ? "user" : "lead",
    }
    attributes[:phone] = phone_number if phone_number.present?
    attributes[:email] = email_address if email_address.present?

    attributes[:external_id] = client.id.to_s if client.present?
    attributes[:client] = client.id.to_s if client.present?
    attributes[:name] = client&.legal_name if client.present?
    puts "Client.present: #{client.present?}"
    puts attributes
    attributes
  end

  def self.create_new_intercom_thread(contact, body)
    # Read https://web.archive.org/web/20230118155416/https://forum.intercom.com/s/question/0D55c00005vHaPsCAK/create-conversation-for-lead-throws-an-error-user-not-found
    # to learn more about why this approach was used (using contact.role vs explicitly setting one).
    intercom.messages.create({ from: { type: contact.role, id: contact.id }, body: body })
  end

  def self.most_recent_conversation(contact_id)
    puts "Looking for conversations with #{contact_id}"
    intercom.conversations.search(
      {
        "sort_field": "updated_at",
        "sort_order": "descending",
        "query": {
          "field": 'contact_ids',
          "operator": 'IN',
          "value": [contact_id]
        }
      }
    ).first
  end

  def self.intercom
    @intercom ||= Intercom::Client.new(token: EnvironmentCredentials.dig(:intercom, :intercom_access_token))
  end
end
