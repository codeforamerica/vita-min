module Hub
  class AssignedClientsController < Hub::BaseController
    FILTER_COOKIE_NAME = "assigned_clients_filters".freeze
    include ClientSortable
    before_action :ensure_always_current_user_assigned, :load_vita_partners, :load_users, only: [:index]
    load_and_authorize_resource :client, parent: false
    before_action :setup_sortable_client, only: [:index]
    layout "hub"

    def index
      @page_title = I18n.t("hub.assigned_clients.index.title")
      @client_sorter.filters[:assigned_to_me] = true
      @tax_return_count = TaxReturn.where(client: @client_sorter.filtered_clients.with_eager_loaded_associations.without_pagination).size
      @clients = @client_sorter.filtered_and_sorted_clients.page(params[:page]).load
      @message_summaries = RecentMessageSummaryService.messages(@clients.map(&:id))
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
