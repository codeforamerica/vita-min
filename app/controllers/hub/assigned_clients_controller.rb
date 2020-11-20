module Hub
  class AssignedClientsController < ApplicationController
    include AccessControllable
    include ClientSortable

    before_action :ensure_always_current_user_assigned
    before_action :require_sign_in
    before_action :setup_sortable_client, only: [:index]
    load_and_authorize_resource :client, parent: false
    layout "admin"

    def index
      @page_title = I18n.t("hub.assigned_clients.index.title")
      @clients = filtered_and_sorted_clients
      render "hub/clients/index"
    end

    def ensure_always_current_user_assigned
      @always_current_user_assigned = true
    end
  end
end