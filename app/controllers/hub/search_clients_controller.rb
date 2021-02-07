module Hub
  class SearchClientsController < ApplicationController
    include AccessControllable
    include ClientSortable
    before_action :require_sign_in, :redirect_unless_admin
    authorize_resource :client, parent: false

    layout 'admin'

    def index
      @page_title = I18n.t("hub.clients.search_clients.title")
      if has_search_and_sort_params? && !params[:clear].present?
        @clients = Client.accessible_by(current_ability)
        @clients = filtered_and_sorted_clients.with_eager_loaded_associations
      else
        @clients = []
      end
      render "hub/clients/index"
    end

    # Product only wants this route available to admins.
    def redirect_unless_admin
      redirect_to hub_clients_path unless current_user.admin?
    end
  end
end