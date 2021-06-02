module Hub
  class UnattendedClientsController < ApplicationController
    FILTER_COOKIE_NAME = "sla_violations_filters".freeze
    include AccessControllable
    include ClientSortable

    before_action :require_sign_in, :load_users

    load_and_authorize_resource :client, parent: false
    load_and_authorize_resource :vita_partner, parent: false
    layout "admin"

    def index
      @page_title = "Clients who haven't received a response in #{day_param} business days"
      @breach_date = day_param.business_days.ago
      @clients = filtered_and_sorted_clients.first_unanswered_incoming_interaction_communication_breaches(@breach_date)
      @filters[:sla_breach_date] = @breach_date
      @tax_return_count = @clients.includes(:tax_returns).page(100_000_000).joins(:tax_returns).size
      @clients = @clients.with_eager_loaded_associations.page(params[:page]).load
      @message_summaries = RecentMessageSummaryService.messages(@clients.map(&:id))
      render "hub/clients/index"
    end

    private

    def day_param
      value = params[:sla_days].to_i
      value > 0 ? value : 3
    end

    def filter_cookie_name
      FILTER_COOKIE_NAME
    end
  end
end
