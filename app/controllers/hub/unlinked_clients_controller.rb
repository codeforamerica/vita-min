module Hub
  class UnlinkedClientsController < ApplicationController
    include AccessControllable
    include ClientSortable

    before_action :require_sign_in
    before_action :load_and_authorize_unlinked_clients
    layout "hub"

    def index
      @page_title = I18n.t("hub.clients.unlinked_clients.title")
      @sort_column = "updated_at"
      @sort_order = params[:order] == "desc" ? "desc" : "asc"
      @clients = Client.where(vita_partner: @vita_partner).order(created_at: @sort_order).with_eager_loaded_associations
    end

    private

    def load_and_authorize_unlinked_clients
      @vita_partner = VitaPartner.client_support_org
      authorize!(:manage, @vita_partner)
    end
  end
end
