module Hub
  class MessagesController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    load_and_authorize_resource :client
    layout "hub"

    def index
      @messages_by_day = MessagePresenter.grouped_messages(@client)
      @outgoing_text_message = OutgoingTextMessage.new(client: @client)
      @outgoing_email = OutgoingEmail.new(client: @client)
    end
  end
end
