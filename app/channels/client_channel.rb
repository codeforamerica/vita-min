class ClientChannel < ApplicationCable::Channel
  def subscribed
    stream_from "client_#{params[:room]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak
  end
end
