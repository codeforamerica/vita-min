module Hub
  class DashboardController < Hub::BaseController
    layout "hub"
    before_action :load_presenters, only: [:index, :show]
    before_action :require_dashboard_user

    def index
      coalition = @presenter.coalitions.first
      if coalition.present?
        redirect_to action: :show, type: Coalition::TYPE, id: coalition.id
        return
      end
      organization = @presenter.organizations.first
      redirect_to action: :show, type: Organization::TYPE, id: organization.id
    end

    def show
      @selected_type = params[:type]
      @selected_id = params[:id].to_i
      @selected = (
        if @selected_type == Organization::TYPE
          @presenter.organizations.find { |organization| organization.id == @selected_id }
        else
          @presenter.coalitions.find { |coalition| coalition.id == @selected_id }
        end
      )
      @filter_options = get_filter_options
    end

    private

    def load_presenters
      @presenter = Hub::OrganizationsPresenter.new(current_ability)
    end

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

    def get_filter_options
      filter_options = []
      @presenter.coalitions.each { |coalition|
        filter_options << coalition
        @presenter.organizations_in_coalition(coalition).each do |organization|
          filter_options << organization
        end
      }
      @presenter.organizations.filter do |organization|
        if organization.coalition_id.nil?
          filter_options << organization
        end
      end
      filter_options
    end
  end
end