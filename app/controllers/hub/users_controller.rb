module Hub
  class UsersController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    load_and_authorize_resource

    layout "admin"

    def profile
      @role_name =
        if OrganizationLeadRole.exists?(user: current_user)
          t("general.organization_lead")
        elsif current_user.is_admin
          t("general.admin")
        elsif current_user.is_client_support
          t("general.client_support")
        else
          ""
        end
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
