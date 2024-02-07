require 'intercom'

class IntercomService
  def self.create_message(email_address:, phone_number:, body:, client:, has_documents:)
    if has_documents && client.present?
      body = [body, "[client sent an attachment, see #{Rails.application.routes.url_helpers.hub_client_documents_url(client_id: client.id)}]"].compact.join(' ')
    end
    return nil if body.blank?

    contact = contact_from_client(client) || contact_from_email(email_address) || contact_from_sms(phone_number)
    most_recent_conversation = most_recent_conversation(contact.id) if contact.present?

    if most_recent_conversation.present?
      # Per https://developers.intercom.com/intercom-api-reference/reference/reply-to-a-conversation
      # type is always user and message_type is always comment.
      Rails.logger.info("Replying to intercom conversation -- intercom contact id ##{contact.id}")
      intercom_api(:conversations,
                   :reply,
                   { id: most_recent_conversation.id, # using conversation ID rather than "last" b/c "last" has been flaky
                     intercom_user_id: contact.id,
                     type: 'user',
                     message_type: 'comment',
                     body: body })
    else
      contact ||= upsert_contact(client: client, email_address: email_address, phone_number: phone_number)
      # Using contact.role as type per https://developers.intercom.com/intercom-api-reference/reference/create-a-message
      intercom_api(:messages, :create, { from: { type: contact.role, id: contact.id }, body: body })
    end
  end

  def self.inform_client_of_handoff(client:, send_sms:, send_email:)
    return if client.blank?

    SendAutomatedMessage.new(
      message: AutomatedMessage::IntercomForwarding,
      sms: send_sms,
      email: send_email,
      client: client
    ).send_messages
  end

  def self.generate_user_hash(user_id)
    cred = EnvironmentCredentials.dig(:intercom, :statefile_secure_mode_secret_key)

    OpenSSL::HMAC.hexdigest(
      'sha256',
      cred,
      user_id.to_s
    ) unless user_id.nil?
  end

  def self.generate_statefile_user_hash(user_id)
    cred = EnvironmentCredentials.dig(:intercom, :statefile_secure_mode_secret_key)

    OpenSSL::HMAC.hexdigest(
      'sha256',
      cred,
      user_id.to_s
    ) unless user_id.nil?
  end

  private

  def self.contact_from_email(email)
    return unless email.present?

    intercom_api(:contacts, :search, {
      "query": {
        "field": 'email',
        "operator": '=',
        "value": email
      }
    })&.first
  end

  def self.contact_from_sms(phone_number)
    return unless phone_number.present?

    intercom_api(:contacts, :search, {
      "query": {
        "field": 'phone',
        "operator": '=',
        "value": phone_number
      }
    })&.first
  end

  def self.contact_from_client(client)
    return unless client.present?

    intercom_api(:contacts, :search, {
      "query": {
        "field": 'external_id',
        "operator": '=',
        "value": client.id&.to_s
      }
    })&.first
  end

  def self.upsert_contact(client:, phone_number:, email_address:)
    intercom_contact = contact_from_client(client) || contact_from_email(email_address) || contact_from_sms(phone_number)

    if intercom_contact.present?
      update_intercom_contact(intercom_contact, client: client, phone_number: phone_number, email_address: email_address)
    else
      begin
        intercom_api(:contacts, :create, intercom_contact_attributes(client: client, phone_number: phone_number, email_address: email_address))
      rescue Intercom::MultipleMatchingUsersError => e
        intercom_contact_id = e.message.match(/id=(\S+)/)[1]
        update_intercom_contact(intercom_contact_id, client: client, phone_number: phone_number, email_address: email_address)
      end
    end
  end

  def self.update_intercom_contact(contact, client:, phone_number:, email_address:)
    contact.from_hash(intercom_contact_attributes(client: client, phone_number: phone_number, email_address: email_address))
    intercom_api(:contacts, :save, contact)
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
    attributes
  end

  def self.most_recent_conversation(contact_id)
    intercom_api(:conversations,
                 :search,
                 {
                   "sort_field": "updated_at",
                   "sort_order": "descending",
                   "query": {
                     "field": 'contact_ids',
                     "operator": 'IN',
                     "value": [contact_id]
                   }
                 }).first
  end

  def self.intercom
    @intercom ||= Intercom::Client.new(token: EnvironmentCredentials.dig(:intercom, :intercom_access_token))
  end

  MAX_RETRY_COUNT = 3

  def self.intercom_api(collection, verb, params)
    if Rails.env.development?
      Rails.logger.debug("Calling Intercom: #{collection}.#{verb}(#{params})")
    end

    retry_counts = 0

    begin
      result = intercom.send(collection).send(verb, params)
    rescue
      Intercom::AuthenticationError => e
        retry_counts += 1
        DatadogApi.increment("intercom.api.authentication_failure_retry")
        retry if retry_counts <= MAX_RETRY_COUNT
        raise e, "Failed #{MAX_RETRY_COUNT} times to authenticate with Intercom"
    end

    if Rails.env.development?
      Rails.logger.debug("Intercom provided response for call: #{result.inspect}")
    end
    result
  end
end
