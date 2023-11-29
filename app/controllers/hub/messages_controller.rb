module Hub
  class MessagesController < Hub::BaseController
    load_and_authorize_resource :client
    layout "hub"

    def index
      @client = HubClientPresenter.new(@client)
    end

    def no_response_needed
      @client.update!(first_unanswered_incoming_interaction_at: nil)
      redirect_to hub_client_messages_path
    end

    private

    class HubClientPresenter < Hub::ClientsController::HubClientPresenter
      def messages_by_day
        @_messages ||= MessagePresenter.grouped_messages(self)
      end
    end
  end
end
