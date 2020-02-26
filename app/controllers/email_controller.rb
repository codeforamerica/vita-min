class EmailController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  # Edit this regex via: https://regex101.com/r/gm4p3C/2
  ZENDESK_SMS_REGEX = /〒\nphone: \+(?<phone_number>[0-9]{11})\nticket_id: (?<ticket_id>[0-9]*)\nbody: (?<body>.+)\n〶/m

  def create
    raise StandardError unless params[:to].include?("zendesk-sms@hooks.vitataxhelp.org")

    body = params[:text]
    match = body.match(ZENDESK_SMS_REGEX)

    raise "Could not parse Zendesk SMS Message" unless match

    is_from_zendesk_text_user = (params[:from].include? "Text user: +") &&
      (params[:from].include? "support@eitc.zendesk.com")

    if is_from_zendesk_text_user
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
end
