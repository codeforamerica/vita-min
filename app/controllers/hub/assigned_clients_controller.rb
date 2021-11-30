module Hub
  class AssignedClientsController < ApplicationController
    FILTER_COOKIE_NAME = "assigned_clients_filters".freeze
    include AccessControllable
    include ClientSortable

    before_action :require_sign_in
    before_action :ensure_always_current_user_assigned, :load_vita_partners, :load_users, :setup_sortable_client, only: [:index]
    load_and_authorize_resource :client, parent: false
    layout "hub"

    def index
      @page_title = I18n.t("hub.assigned_clients.index.title")
      # @tax_return_count HAS to be defined before @clients, otherwise it will cause SQL errors
      @tax_return_count = TaxReturn.where(client: filtered_clients.with_eager_loaded_associations.without_pagination).size
      @clients = filtered_and_sorted_clients.with_eager_loaded_associations.page(params[:page]).load
      @message_summaries = RecentMessageSummaryService.messages(@clients.map(&:id))
      @filters[:assigned_to_me] = true
      render "hub/clients/index"
    end

    private

    def filter_cookie_name
      FILTER_COOKIE_NAME
    end

    def ensure_always_current_user_assigned
      @always_current_user_assigned = true
    end

    def load_vita_partners
      @vita_partners = VitaPartner.accessible_by(current_ability)
    end
  end
end
