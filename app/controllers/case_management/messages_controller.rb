module CaseManagement
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
        @contact_history = (
          @outgoing_text_messages.includes(:user) +
          @incoming_text_messages +
          @outgoing_emails.includes(:user) +
          @incoming_emails
        ).sort_by(&:datetime)
        @messages_by_day = @contact_history.group_by { |message| message.datetime.beginning_of_day }
        @outgoing_text_message = OutgoingTextMessage.new(client: @client)
        @outgoing_email = OutgoingEmail.new(client: @client)
      end
    end
end