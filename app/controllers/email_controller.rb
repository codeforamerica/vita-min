class EmailController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def create
    raise StandardError unless params[:to].include?("zendesk-sms@vitataxhelp.org")

    body = params[:text]
    # https://regex101.com/r/gm4p3C/2
    regex = /〒\nphone: \+(?<phone_number>[0-9]{11})\nticket_id: (?<ticket_id>[0-9]*)\nbody: (?<body>.+)\n〶/m
    matches_hash = body.match(regex).named_captures
    @zendesk_ticket_id = matches_hash["ticket_id"].to_i
    @phone_number = matches_hash["phone_number"]
    @message_body = matches_hash["body"]
    render status: 200, json: "success"
  end
end