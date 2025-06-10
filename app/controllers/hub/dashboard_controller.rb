module Hub
  class DashboardController < Hub::BaseController
    layout "hub"
    before_action :require_dashboard_user
    helper_method :presenter
    helper_method :capacity_css_class

    def index
      model = presenter.filter_options.first.model
      redirect_to action: :show, type: model.class.name.downcase, id: model.id
    end

    def presenter
      @presenter ||= Hub::Dashboard::DashboardPresenter.new(
        current_user,
        current_ability,
        "#{params[:type]}/#{params[:id]}",
        params[:stage],
        (params[:page] || 1)
      )
    end

    private

    def require_dashboard_user
      unless current_user.has_dashboard_access?
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

    def capacity_css_class(organization)
      if organization.active_client_count > (organization.capacity_limit || 0)
        "over-capacity"
      elsif organization.active_client_count < (organization.capacity_limit || 0)
        "under-capacity"
      else
        "at-capacity"
      end
    end
  end
end