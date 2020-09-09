class OutgoingTextMessagesController < ApplicationController
  include TwilioRequestable

  def update
    OutgoingTextMessage.find(params[:id]).update(twilio_status: params["MessageStatus"])
    head :ok
  end
end
