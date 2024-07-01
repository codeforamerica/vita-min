module Hub
  class DashboardController < Hub::BaseController
    layout "hub"
    before_action :load_vita_partners, only: [:index, :show]
    # TODO: Require specific roles

    def index
      redirect_to action: :show, id: @vita_partners.first.id
    end

    def show
      @selected_id = params[:id].to_i
      @vita_partner = @vita_partners.find { |vita_partner| vita_partner.id == @selected_id }
    end
  end
end