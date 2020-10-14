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

  def self.broadcast_contact_record(contact_record)
    broadcast_to(contact_record.client, [ApplicationController.render(partial: 'shared/message_list_contact_record', locals: { contact_record: contact_record })])
  end
end
