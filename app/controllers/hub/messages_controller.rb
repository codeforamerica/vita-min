module Hub
  class MessagesController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    load_and_authorize_resource :client
    layout "hub"

    def index
      @client = HubClientPresenter.new(@client)
    end

    private

    class HubClientPresenter < Hub::ClientsController::HubClientPresenter
      def outgoing_text_message
        OutgoingTextMessage.new(client: @client)
      end

      def outgoing_email
        OutgoingEmail.new(client: @client)
      end

      def messages_by_day
        @_messages ||= MessagePresenter.grouped_messages(@client)
      end
    end
  end
end
