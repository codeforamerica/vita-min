module Hub
  class UsersController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    load_and_authorize_resource
    load_and_authorize_resource :vita_partner, collection: [:edit, :update], parent: false
    before_action :authorize_vita_partner_updates, only: :update
    layout "admin"

    def profile; end

    def index
      @users = @users.includes(:memberships)
    end

    def edit; end

    def update
      return render :edit unless update_user
      redirect_to edit_hub_user_path(id: @user), notice: I18n.t("general.changes_saved")
    end

    private
    def update_user
      @user.update(user_params)
    end

    def authorize_vita_partner_updates
      user_params[:memberships_attributes].values.map { |v| authorize!(:manage, VitaPartner.find(v[:vita_partner_id])) }
    end

    def user_params
      params.require(:user).permit(
        *(:is_admin if current_user.is_admin?),
        :timezone,
        memberships_attributes: {}
      )
    end
  end
end
