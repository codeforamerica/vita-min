class IncomingTextMessagesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :validate_twilio_request

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

  private

  def validate_twilio_request
    return head 403 unless TwilioService.valid_request?(request)
  end
end
