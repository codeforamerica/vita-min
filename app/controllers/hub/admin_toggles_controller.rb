module Hub
  class AdminTogglesController < Hub::BaseController
    layout "hub"
    load_and_authorize_resource

    def index
      @form = AdminToggle.new
      @recent_toggles = AdminToggle.where(name: params[:name]).last(5).reverse
    end

    def create
      value = if AdminToggle::BOOLEAN_FLAGS.include?(admin_toggle_params[:name])
                params[:admin_toggle][:value] == 'true'
              end

      AdminToggle.create(admin_toggle_params.merge(user: current_user, value: value))
      redirect_to action: :index, name: params[:admin_toggle][:name]
    end

    private

    def admin_toggle_params
      params.require(:admin_toggle).permit(:name)
    end
  end
end