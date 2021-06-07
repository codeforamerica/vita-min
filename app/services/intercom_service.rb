class IntercomService
  # create an intercomlead model that stores lead ids
  def create_message_from_user(body, lead)
    message_properties = {
      from: {
        type: "user",
        id: lead.id #user_id/lead_id
      },
      body: body
    }
    message = @intercom.messages.create(message_properties)

    message.id
  end

  def create_intercom_message_from_email(incoming_email)
    email = incoming_email.client.intake.email_address
    lead_from_email = lead_from_email(email)
    if lead_from_email.present?
      intercom.messages.create(body: incoming_email.body, lead: lead_from_email)
    else
      new_lead = intercom.create_lead(email)
      intercom.messages.create(body: incoming_email.body, lead: new_lead)
    end
    #  if intercom client can find a lead with this email
    #   create new lead and new message
    # else
    #   create new message for lead
  end

  def create_lead_by_email

  end

  def lead_from_email(email)
    @intercom.contacts.search(
      "query": {
        "field": 'email',
        "operator": '=',
        "value": email
      }
    )
  end

  private

  def intercom

      Intercom::Client.new(token: "dG9rOjNmYmU5NzhiXzBmMGRfNDc2Zl85NTU1XzRmMDdjODI5Yjg5MzoxOjA=")
      @intercom ||= Intercom::Client.new(token: EnvironmentCredentials.dig(:intercom, :intercom_access_token))
  end
end