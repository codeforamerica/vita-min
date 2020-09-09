class IncomingTextMessagesController < ApplicationController
  include TwilioRequestable

  def create
    phone_number = Phonelib.parse(params["From"]).sanitized
    case_file = CaseFile.where(phone_number: phone_number).or(CaseFile.where(sms_phone_number: phone_number)).first
    unless case_file.present?
      case_file = CaseFile.create!(phone_number: phone_number, sms_phone_number: phone_number)
    end

    IncomingTextMessage.create!(
      body: params["Body"],
      received_at: DateTime.now,
      from_phone_number: phone_number,
      case_file: case_file,
    )
    head :ok
  end
end
