module Hub
  class UsersController < Hub::BaseController
    include RoleHelper

    # TODO: remove CanCan loads in GYR1-757
    before_action :load_groups, only: [:edit_role, :update_role]
    before_action :load_and_authorize_role, only: [:update_role]
    load_and_authorize_resource unless Flipper.enabled?(:use_pundit)

    after_action :verify_authorized, if: -> (c) do
                                       # TODO: When we remove use_pundit flag if block remember to add "except: [:profile]"
                                       return false if c.action_name == "profile"
                                       return false unless Flipper.enabled?(:use_pundit)
                                     end
    after_action :verify_policy_scoped, if: -> (c) do
                                         return false unless Flipper.enabled?(:use_pundit)
                                       end, only: :index
    before_action :set_and_authorize_user, except: %i[index profile resend_invitation]
    before_action :set_and_authorize_users, only: %i[index]

    layout "hub"

    def profile; end

    def index
      role_type = role_type_from_role_name(params[:search])
      vita_partner = vita_partner_from_search(params[:search])

      if params[:search].present?
        @users = if role_type.present?
                   @users.search(role_type)
                 elsif vita_partner.present?
                   if vita_partner.is_a?(Organization)
                     @users.where(role: OrganizationLeadRole.where(organization: vita_partner))
                   elsif vita_partner.is_a?(Site)
                     @users.where(role: SiteCoordinatorRole.assignable_to_sites(vita_partner))
                           .or(@users.where(role: TeamMemberRole.assignable_to_sites([vita_partner])))
                   elsif vita_partner.is_a?(Coalition)
                     @users.where(role: CoalitionLeadRole.where(coalition: vita_partner))
                   end
                 else
                   @users.search(params[:search])
                 end
      end
      @users = @users.order(suspended_at: :desc)
      @users = @users.page(params[:page])
    end

    def edit; end

    def edit_role
      @role = role_from_params(params[:role], params)
      raise ActionController::RoutingError, 'Not Found' unless @role

      if @user.role.respond_to?(:sites) && @role.respond_to?(:sites)
        @role.sites = @user.role.sites
      end
    end

    def update_role
      old_role = @user.role
      if @role.valid?
        old_assigned_client_ids = Client.assigned_to(@user).pluck('id')
        @user.update(role: @role)
        inaccessable_clients = Client.where(id: old_assigned_client_ids).where.not(id: Client.accessible_to_user(@user))
        TaxReturn.where(client: inaccessable_clients, assigned_user: @user).update_all(assigned_user_id: nil)
        old_role.destroy
        flash[:notice] = I18n.t("hub.users.update_role.success", name: @user.name)
        redirect_to edit_hub_user_path
      else
        render :edit_role
      end
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
      authorize!(:update, @user) unless Flipper.enabled?(:use_pundit) # TODO: remove CanCan authorizations in GYR1-757
      @user.unlock_access! if @user.access_locked?
      flash[:notice] = I18n.t("hub.users.unlock.account_unlocked", name: @user.name)
      redirect_to(hub_users_path)
    end

    def suspend
      authorize!(:update, @user) unless Flipper.enabled?(:use_pundit)
      @user.suspend!
      redirect_to edit_hub_user_path(id: @user), notice: I18n.t("hub.users.suspend.success", name: @user.name)
    end

    def unsuspend
      authorize!(:update, @user) unless Flipper.enabled?(:use_pundit)
      @user.activate!
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

      if Flipper.enabled?(:use_pundit)
        authorize user
      else
        return unless current_ability.can?(:manage, user)
      end

      user&.invite!(current_user)
      flash[:notice] = "Invitation re-sent to #{user.email}"

      redirect_to hub_users_path
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

    def vita_partner_from_search(search_param)
      current_ability = Ability.new(current_user)
      Organization.accessible_by(current_ability).find_by(name: search_param) ||
        Site.accessible_by(current_ability).find_by(name: search_param) ||
        Coalition.accessible_by(current_ability).find_by(name: search_param)
    end

    def load_and_authorize_role
      @role = role_from_params(params.dig(:user, :role), params)

      authorize!(:create, @role)
    end

    def set_and_authorize_user
      return unless Flipper.enabled?(:use_pundit)

      @user ||= User.find(params[:id])
      authorize @user
    end

    def set_and_authorize_users
      return unless Flipper.enabled?(:use_pundit)

      @users ||= policy_scope(User)
      authorize User
    end
  end
end
