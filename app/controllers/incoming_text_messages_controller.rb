class IncomingTextMessagesController < ApplicationController
  include TwilioRequestable

  def create
    phone_number = Phonelib.parse(params["From"]).sanitized
    client = Client.where(phone_number: phone_number).or(Client.where(sms_phone_number: phone_number)).first
    unless client.present?
      client = Client.create!(phone_number: phone_number, sms_phone_number: phone_number)
    end

    IncomingTextMessage.create!(
      body: params["Body"],
      received_at: DateTime.now,
      from_phone_number: phone_number,
      client: client,
    )
    head :ok
  end
end
