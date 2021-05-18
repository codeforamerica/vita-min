module Hub
  class UsersController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    before_action :load_groups, only: [:edit_role, :update_role]
    before_action :load_and_authorize_role, only: [:update_role]
    load_and_authorize_resource

    layout "admin"

    def profile; end

    def index
      @users = @users.search(params[:search]) if params[:search].present?
      @users = @users.page(params[:page])
    end

    def edit; end

    def edit_role; end

    def update_role
      old_role = @user.role
      @user.update!(role: @role)
      old_role.delete
      flash[:notice] = I18n.t("hub.users.update_role.success", name: @user.name)
      redirect_to edit_hub_user_path
    end

    def destroy
      begin
        ActiveRecord::Base.transaction do
          # if user deletion fails, don't destroy their role
          @user.role.destroy!
          @user.destroy!
        end
        flash_message = I18n.t("hub.users.destroy.success", name: @user.name)
      rescue ActiveRecord::InvalidForeignKey
        @user.suspend!
        flash_message = I18n.t("hub.users.suspend.success", name: @user.name)
      end
      redirect_to hub_users_path, notice: flash_message
    end

    def unlock
      authorize!(:update, @user)
      @user.unlock_access! if @user.access_locked?
      flash[:notice] = I18n.t("hub.users.unlock.account_unlocked", name: @user.name)
      redirect_to(hub_users_path)
    end

    def suspend
      authorize!(:update, @user)
      @user.suspend!
      redirect_to edit_hub_user_path(id: @user), notice: I18n.t("hub.users.suspend.success", name: @user.name)
    end

    def unsuspend
      authorize!(:update, @user)
      @user.update!(suspended_at: nil)
      redirect_to edit_hub_user_path(id: @user), notice: I18n.t("hub.users.unsuspend.success", name: @user.name)
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
        :name,
        :phone_number,
        :timezone,
      )
    end

    def load_groups
      @vita_partners = current_user.accessible_vita_partners
      @coalitions = current_user.accessible_coalitions
    end

    def load_and_authorize_role
      @role =
        case params.dig(:user, :role)
        when OrganizationLeadRole::TYPE
          OrganizationLeadRole.new(organization: @vita_partners.find(params.require(:organization_id)))
        when CoalitionLeadRole::TYPE
          CoalitionLeadRole.new(coalition: @coalitions.find(params.require(:coalition_id)))
        when AdminRole::TYPE
          AdminRole.new
        when SiteCoordinatorRole::TYPE
          SiteCoordinatorRole.new(site: @vita_partners.find(params.require(:site_id)))
        when ClientSuccessRole::TYPE
          ClientSuccessRole.new
        when GreeterRole::TYPE
          GreeterRole.new
        when TeamMemberRole::TYPE
          TeamMemberRole.new(site: @vita_partners.sites.find(params.require(:site_id)))
        end

      authorize!(:create, @role)
    end
  end
end
