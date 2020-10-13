class ClientChannel < ApplicationCable::Channel
  def subscribed
    begin
      @client = Client.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      reject
    end

    unless current_ability.can? :read, @client
      reject
    end

    stream_for @client
  end
end
