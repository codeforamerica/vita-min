module Hub
  class AdminTogglesController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    layout "hub"

    def index
      @form = AdminToggle.new
      @recent_toggles = AdminToggle.where(name: params[:name]).last(5).reverse
    end

    def create
      value = if AdminToggle::BOOLEAN_FLAGS.include?(params[:admin_toggle][:name])
                params[:admin_toggle][:value] == 'true'
              end

      AdminToggle.create(user: current_user, name: params[:admin_toggle][:name], value: value)
      redirect_to action: :index, name: params[:admin_toggle][:name]
    end
  end
end