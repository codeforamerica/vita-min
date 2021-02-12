module Hub
  class UsersController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    before_action :load_and_authorize_groups, only: [:edit_role, :update_role]
    before_action :load_and_authorize_role, only: [:update_role]
    load_and_authorize_resource

    layout "admin"

    def profile; end

    def index
      @users = @users.search(params[:search]) if params[:search].present?
      @users = @users.page(params[:page])
    end

    def edit; end

    def edit_role
    end

    def update_role
      old_role = @user.role
      @user.update!(role: @role)
      old_role.delete
      flash[:notice] = "Updated role"
      redirect_to hub_users_path
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
        @user.assigned_tax_returns.update(assigned_user: nil)
        @user.update!(suspended_at: DateTime.now)
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

    def load_and_authorize_groups
      @vita_partners = current_user.accessible_vita_partners
      @coalitions = current_user.accessible_coalitions
    end

    def load_and_authorize_role
      puts(params)
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
          greeter_params = params.require(:greeter_organization_join_record).permit(organization_ids: []).merge(
            params.require(:greeter_coalition_join_record).permit(coalition_ids: [])
          )
          GreeterRole.new(
            coalitions: @coalitions.where(id: greeter_params[:coalition_ids]),
            organizations: @vita_partners.organizations.where(id: greeter_params[:organization_ids]),
            )
        when TeamMemberRole::TYPE
          TeamMemberRole.new(site: @vita_partners.sites.find(params.require(:site_id)))
        end

      authorize!(:create, @role)
    end
  end
end
