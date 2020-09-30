class ClientChannel < ApplicationCable::Channel
  def subscribed
    client = Client.find(params[:id])
    stream_for client
  end

  def unsubscribed
    # Empty; we could add cleanup logic here
  end
end
