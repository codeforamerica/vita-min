module Hub
  class ClientSelectionsController < ApplicationController
    include AccessControllable
    include ClientSortable

    layout "admin"

    before_action :require_sign_in, :load_vita_partners, :load_users

    def show
      @client_filter_form_path = hub_clients_path
      @client_selection = ClientSelection.find(params[:id])
      @clients = Client.accessible_by(current_ability).where(id: @client_selection.clients)
      @client_index_help_text = I18n.t("hub.client_selections.client_selection_help_text", count: @clients.size)
      inaccessible_client_count = @client_selection.clients.where.not(id: @clients).size
      if inaccessible_client_count > 0
        missing_results_message = I18n.t("hub.client_selections.client_selection_help_text_missing_results", count: inaccessible_client_count)
        @client_index_help_text += " #{missing_results_message}"
      end
      @clients = filtered_and_sorted_clients.page(params[:page])
      @page_title = I18n.t("hub.client_selections.page_title", count: @client_selection.clients.size, id: @client_selection.id)

      render "hub/clients/index"
    end

    private

    def filter_cookie_name; end
  end
end