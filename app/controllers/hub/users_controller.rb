module Hub
  class UsersController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    load_and_authorize_resource

    layout "admin"

    def profile; end

    def index
      @users = @users.page(params[:page])
    end

    def edit; end

    def destroy
      if @user.assigned_tax_returns.exists?
        redirect_to edit_hub_user_path(id: @user), alert: I18n.t("hub.users.destroy.user_has_assignments", name: @user.name, client_id: @user.assigned_tax_returns.first.client_id)
      else
        # For now, raise an error if more things are linked to the user. In the future, we probably want to "suspend" or "archive".
        ActiveRecord::Base.transaction do
          # if user deletion fails, don't destroy their role
          @user.role.destroy!
          @user.destroy!
        end
        redirect_to hub_users_path, notice: I18n.t("hub.users.destroy.success", name: @user.name)
      end
    end

    def unlock
      authorize!(:update, @user)
      @user.unlock_access! if @user.access_locked?
      flash[:notice] = I18n.t("hub.users.unlock.account_unlocked", name: @user.name)
      redirect_to(hub_users_path)
    end

    def update
      update_params = user_params
      old_role = nil
      if current_user.admin? && !@user.admin? && params[:user][:is_admin] == "true"
        update_params = user_params.merge!(role: AdminRole.new)
        old_role = @user.role
      end
      if @user.update(update_params)
        old_role&.destroy
        redirect_to edit_hub_user_path(id: @user), notice: I18n.t("general.changes_saved")
      else
        render :edit
      end
    end

    def resend_invitation
      user = User.find_by(id: params[:user_id])

      if current_ability.can?(:manage, user)
        user&.invite!(current_user)
        flash[:notice] = "Invitation re-sent to #{user.email}"

        redirect_to hub_users_path
      end
    end

    private

    def user_params
      params.require(:user).permit(
        :phone_number,
        :timezone,
      )
    end
  end
end
