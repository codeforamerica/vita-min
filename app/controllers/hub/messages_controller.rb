module Hub
  class MessagesController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    load_and_authorize_resource :client
    load_and_authorize_resource :outgoing_text_message, parent: false, through: :client
    load_and_authorize_resource :incoming_text_message, parent: false, through: :client
    load_and_authorize_resource :outgoing_email, parent: false, through: :client
    load_and_authorize_resource :incoming_email, parent: false, through: :client

    layout "admin"

    def index
      @messages_by_day = MessagePresenter.grouped_messages(@client)
      @outgoing_text_message = OutgoingTextMessage.new(client: @client)
      @outgoing_email = OutgoingEmail.new(client: @client)
    end
  end
end
