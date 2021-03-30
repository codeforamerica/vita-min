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
      @clients = filtered_and_sorted_clients.page(params[:page])
      @client_index_help_text = I18n.t("hub.client_selections.client_selection_help_text", count: @client_selection.clients.size)

      render "hub/clients/index"
    end

    private

    def filter_cookie_name; end
  end
end