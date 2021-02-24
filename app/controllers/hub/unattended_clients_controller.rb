module Hub
  class UnattendedClientsController < ApplicationController
    include AccessControllable
    include ClientSortable

    before_action :require_sign_in, :load_users

    load_and_authorize_resource :client, parent: false
    load_and_authorize_resource :vita_partner, parent: false

    layout "admin"

    def index
      @page_title = "Clients who haven't received a response in #{day_param} business days"
      @breach_date = day_param.business_days.ago
      @clients = filtered_and_sorted_clients.response_needed_breaches(@breach_date)
      @clients = @clients.with_eager_loaded_associations.page(params[:page])
      @show_first_unanswered_incoming_interaction_at = true if current_user.admin?
      render "hub/clients/index"
    end

    private

    def day_param
      value = params[:sla_days].to_i
      value > 0 ? value : 3
    end
  end
end
