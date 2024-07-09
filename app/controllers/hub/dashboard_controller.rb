module Hub
  class DashboardController < Hub::BaseController
    layout "hub"
    before_action :load_vita_partners, only: [:index, :show]
    before_action :require_dashboard_user

    def index
      redirect_to action: :show, id: @vita_partners.first.id
    end

    def show
      @selected_id = params[:id].to_i
      @vita_partner = @vita_partners.find { |vita_partner| vita_partner.id == @selected_id }
    end

    private

    def require_dashboard_user
      is_dashboard_user = (
        current_user.admin? ||
        current_user.coalition_lead? ||
        current_user.org_lead? ||
        current_user.site_coordinator?
      )
      unless is_dashboard_user
        respond_to do |format|
          format.html do
            session[:after_login_path] = request.original_fullpath
            redirect_to new_user_session_path
          end
          format.js do
            head :forbidden
          end
        end
      end
    end
  end
end