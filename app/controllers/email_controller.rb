class EmailController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  # Edit this regex via: https://regex101.com/r/gm4p3C/2
  ZENDESK_SMS_REGEX = /〒\nphone: \+(?<phone_number>[0-9]{11})\nticket_id: (?<ticket_id>[0-9]*)\nbody: (?<body>.+)\n〶/m

  def create
    unless sent_to_known_email_hook?
      raise StandardError.new("Email webhook received invalid email to #{params[:to]}")
    end

    unless valid_update_from_user? || from_agent_replying_to_thread?
      raise StandardError.new("Email webhook got an unexpected message (#{params[:subject]}) from: #{params[:from]}")
    end

    if valid_update_from_user?
      @zendesk_ticket_id = regex_match["ticket_id"].to_i
      @phone_number = regex_match["phone_number"]
      @message_body = regex_match["body"]

      ZendeskInboundSmsJob.perform_later(
        sms_ticket_id: @zendesk_ticket_id,
        phone_number: @phone_number,
        message_body: @message_body
      )
    end

    render status: 200, json: "success"
  end

  private

  def regex_match
    params[:text].match(ZENDESK_SMS_REGEX)
  end

  def valid_update_from_user?
    from_known_text_trigger? && regex_match
  end

  def sent_to_known_email_hook?
    to_emails = [
      "zendesk-sms@hooks.vitataxhelp.org",
      "zendesk-sms@hooks.getyourrefund.org",
    ]
    to_param = params[:to]
    to_emails.map { |email| to_param.include? email }.any?
  end

  def from_valid_sender?
    from_param = params[:from]
    valid_from_emails = [
      "support@eitc.zendesk.com",
      "support@unitedwaytucson.zendesk.com",
    ]
    valid_from_emails.map { |email| from_param.include? email }.any?
  end

  def from_known_text_trigger?
    from_text_user = params[:from].include? "Text user: +"
    from_valid_sender? && from_text_user
  end

  def from_agent_replying_to_thread?
    from_valid_sender? && (
      params[:subject].include?("Update to SMS Ticket") ||
        params[:subject].include?("New SMS Response")
    )
  end
end
