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
    message = ApplicationController.render(partial: 'hub/messages/contact_record', locals: { contact_record: contact_record })
    if message.size > 7000
      # In the case the message is too big for ActionCable + Postgres, ask the user to reload
      message = I18n.t("hub.client_channel.please_reload_html")
    end
    broadcast_to(contact_record.client, [message])
  end
end
