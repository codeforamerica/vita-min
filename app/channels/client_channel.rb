class ClientChannel < ApplicationCable::Channel
  def subscribed
    # TODO: authz
    client = Client.find(params[:id])
    stream_for client
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak
  end
end
