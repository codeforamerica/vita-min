class IntercomService
  def create_intercom_message_from_email(incoming_email)
    email = incoming_email.client.intake.email_address
    contact_id_from_email = contact_id_from_email(email)
    contact_id = contact_id_from_email.present? ? contact_id_from_email : intercom.contacts.create(email: email, role: "contact").id
    intercom.messages.create({
                               from: {
                                 type: "contact",
                                 id: contact_id
                               },
                               body: incoming_email.body
                             })
  end

  def contact_id_from_email(email)
    contact = intercom.contacts.find(email: email).to_hash
    contact["data"][0]["id"]
  end

  private

  def intercom
    @intercom ||= Intercom::Client.new(token: EnvironmentCredentials.dig(:intercom, :intercom_access_token)) #need to add access token
  end
end