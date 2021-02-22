module Hub
  class UnattendedClientsController < ApplicationController
    include AccessControllable
    include ClientSortable

    before_action :require_sign_in
    before_action :require_admin

    load_and_authorize_resource :client, parent: false
    load_and_authorize_resource :vita_partner, parent: false

    layout "admin"

    def index
      @page_title = "Clients who haven't received a response in #{day_param} business days"
      @breach_date = day_param.business_days.ago
      @clients = filtered_and_sorted_clients(
        default_order: { first_unanswered_incoming_interaction_at: :asc }
      )
      response_breaches = Client.where("first_unanswered_incoming_interaction_at <= ?", @breach_date)
      attention_breaches = Client.where("attention_needed_since <= ?", @breach_date)
      any_breach = response_breaches.or(attention_breaches).sla_tracked
      @clients = @clients.where(id: any_breach)
      @clients = @clients.with_eager_loaded_associations.page(params[:page])
      render "hub/clients/index"
    end

    private

    def day_param
      value = params[:sla_days].to_i
      value > 0 ? value : 3
    end

    def require_admin
      raise CanCan::AccessDenied unless current_user&.admin?
    end
  end
end
