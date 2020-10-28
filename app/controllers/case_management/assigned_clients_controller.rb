module CaseManagement
  class AssignedClientsController < ApplicationController
    include AccessControllable
    include ClientSortable

    before_action :require_sign_in
    before_action :setup_sortable_client, only: [:index]
    load_and_authorize_resource :client, parent: false
    layout "admin"

    def index
      @page_title = I18n.t("case_management.assigned_clients.index.title")
      @clients = @clients.assigned_to(current_user).delegated_order(@sort_column, @sort_order)
      render "case_management/clients/index"
    end
  end
end