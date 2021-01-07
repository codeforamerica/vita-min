module Hub
  class UsersController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    load_and_authorize_resource

    layout "admin"

    def profile; end

    def index; end

    def edit; end

    def update
      model_params = user_params.except(:is_admin)
      saved_ok = @user.update(model_params)
      if saved_ok
        if user_params[:is_admin] && @user.role_type != AdminRole::TYPE
          @user.role.destroy if @user.role.present?
          @user.update!(role: AdminRole.create)
        end
        redirect_to edit_hub_user_path(id: @user), notice: I18n.t("general.changes_saved")
      else
        render :edit
      end
    end

    private

    def user_params
      params.require(:user).permit(
        *(:is_admin if current_user.role_type == AdminRole::TYPE),
        *(:is_client_support if current_user.role_type == AdminRole::TYPE),
        :phone_number,
        :timezone,
      )
    end
  end
end
