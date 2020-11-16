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
      @clients = filtered_and_sorted_clients(assigned_to: current_user)
      render "case_management/clients/index"
    end
  end
end