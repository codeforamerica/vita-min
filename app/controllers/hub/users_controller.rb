module Hub
  class UsersController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    load_and_authorize_resource

    layout "admin"

    def profile
    end

    def index
      @users = @users.includes(:vita_partner)
    end

    def edit
    end

    def update
      return render :edit unless @user.update(user_params)

      redirect_to edit_hub_user_path(id: @user), notice: I18n.t("general.changes_saved")
    end

    private

    def user_params
      params.require(:user).permit(
        *(:is_admin if current_user.is_admin?),
        *(:is_client_support if current_user.is_admin?),
        :timezone,
        current_user.is_admin ? { supported_organization_ids: [] } : {},
      )
    end
  end
end
