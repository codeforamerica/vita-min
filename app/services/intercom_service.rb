require 'intercom'

class IntercomService
  def create_intercom_message_from_email(incoming_email)
    email = incoming_email.client.intake.email_address
    body = incoming_email.body
    contact_id_from_email = contact_id_from_email(email)
    contact_id = contact_id_from_email.present? ? contact_id_from_email : intercom.contacts.create(email: email, role: "contact").id

    if contact_id_from_email.present? && most_recent_conversation(contact_id).present?
      reply_to_existing_intercom_thread(email, contact_id, body)
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

  def create_new_intercom_thread(contact_id, body)
    intercom.messages.create({ from: { type: "contact", id: contact_id }, body: body })
  end

  def reply_to_existing_intercom_thread(email, contact_id, body)
    intercom.conversations.reply_to_last(
      email: email,
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
    @intercom ||= Intercom::Client.new(token: EnvironmentCredentials.dig(:intercom, :intercom_access_token)) #need to add access token
  end
end