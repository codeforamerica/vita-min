module Hub
  class ClientSelectionsController < ApplicationController
    include AccessControllable
    include ClientSortable

    layout "admin"

    before_action :require_sign_in, :load_vita_partners, :load_users
    before_action :load_client_selection, only: [:show, :bulk_action]

    def show
      @client_filter_form_path = hub_clients_path
      @clients = Client.accessible_by(current_ability).where(id: @client_selection.clients)
      @client_index_help_text = I18n.t("hub.client_selections.client_selection_help_text", count: @clients.size)
      inaccessible_client_count = @client_selection.clients.where.not(id: @clients).size
      @missing_results_message = I18n.t("hub.client_selections.client_selection_help_text_missing_results", count: inaccessible_client_count) unless inaccessible_client_count.zero?

      @clients = filtered_and_sorted_clients.page(params[:page])
      @page_title = I18n.t("hub.client_selections.page_title", count: @client_selection.clients.size, id: @client_selection.id)

      render "hub/clients/index"
    end

    def bulk_action
      @client_count = @client_selection.clients.size
    end

    private

    def filter_cookie_name; end

    def load_client_selection
      @client_selection = ClientSelection.find(params[:id])
    end
  end
end
