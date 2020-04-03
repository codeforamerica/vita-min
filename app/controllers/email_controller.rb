class EmailController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  # Edit this regex via: https://regex101.com/r/gm4p3C/2
  ZENDESK_SMS_REGEX = /〒\nphone: \+(?<phone_number>[0-9]{11})\nticket_id: (?<ticket_id>[0-9]*)\nbody: (?<body>.+)\n〶/m

  def create
    raise StandardError unless sent_to_known_email_hook?

    body = params[:text]
    match = body.match(ZENDESK_SMS_REGEX)

    raise "Could not parse incoming message (#{params[:subject]}) from: #{params[:from]}" unless match

    if from_known_text_trigger?
      @zendesk_ticket_id = match["ticket_id"].to_i
      @phone_number = match["phone_number"]
      @message_body = match["body"]

      ZendeskInboundSmsJob.perform_later(
        sms_ticket_id: @zendesk_ticket_id,
        phone_number: @phone_number,
        message_body: @message_body
      )
    end

    render status: 200, json: "success"
  end

  private

  def sent_to_known_email_hook?
    to_emails = [
      "zendesk-sms@hooks.vitataxhelp.org",
      "zendesk-sms@hooks.getyourrefund.org",
    ]
    to_param = params[:to]
    to_emails.map { |email| to_param.include? email }.any?
  end

  def from_known_text_trigger?
    from_param = params[:from]
    valid_from_emails = [
      "support@eitc.zendesk.com",
      "support@unitedwaytucson.zendesk.com",
    ]
    from_valid_sender = valid_from_emails.map { |email| from_param.include? email }.any?
    from_text_user = params[:from].include? "Text user: +"
    from_valid_sender && from_text_user
  end
end
