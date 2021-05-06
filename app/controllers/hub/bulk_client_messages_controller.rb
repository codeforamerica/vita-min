module Hub
  class BulkClientMessagesController < ApplicationController
    include AccessControllable
    include ClientSortable

    layout "admin"

    before_action :require_sign_in, :load_vita_partners, :load_users
    before_action :load_bulk_message, :load_selection, :load_clients, only: [:show]

    def show
      @client_filter_form_path = hub_clients_path
      @client_index_help_text = I18n.t("hub.tax_return_selections.help_text", count: @clients.size)
      @missing_results_message = I18n.t("hub.tax_return_selections.help_text_missing_results", count: @inaccessible_clients_count) unless @inaccessible_clients_count == 0

      @clients = filtered_and_sorted_clients.page(params[:page])
      @page_title = I18n.t("hub.tax_return_selections.page_title", count: @selection.clients.size, id: @selection.id)
      render "hub/clients/index"
    end

    private

    def filter_cookie_name; end

    def load_bulk_message
      @bulk_message = BulkClientMessage.find(params[:id])
    end

    def load_selection
      @selection = @bulk_message.tax_return_selection
    end

    def load_clients
      @clients = @selection.clients
      case params[:status]
      when BulkClientMessage::SUCCEEDED
        @clients = @bulk_message.clients_with_successfully_sent_messages
      when BulkClientMessage::FAILED
        @clients = @bulk_message.clients_with_no_successfully_sent_messages
      when BulkClientMessage::IN_PROGRESS
        @clients = @bulk_message.clients_with_in_progress_messages
      end

      accessible_clients = @clients.accessible_by(current_ability)
      @inaccessible_clients_count = @clients.where.not(id: accessible_clients).size
      @clients = accessible_clients
    end
  end
end
