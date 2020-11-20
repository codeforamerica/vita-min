module Hub
  class UsersController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    load_and_authorize_resource
    load_and_authorize_resource :vita_partner, collection: [:edit, :update], parent: false
    before_action :authorize_vita_partner_updates, only: :update
    layout "admin"

    def profile;end

    def index
      @users = @users.includes(:vita_partner)
    end

    def edit
      @user.vita_partner_id = @user.memberships.find_by(role: "member")&.vita_partner_id
      @user.supported_organization_ids = @user.memberships.where(role: "lead").pluck(:vita_partner_id)
    end

    def update
      authorize_vita_partner_updates
      return render :edit unless update_user
      redirect_to edit_hub_user_path(id: @user), notice: I18n.t("general.changes_saved")
    end

    private
    # To leave the view as-is but allow the ability to save as memberships, we're doing the simplest thing possible:
    # blowing away and recreating memberships on every update.
    def update_user
      ApplicationRecord.transaction do
        @user.memberships.destroy_all && @user.update!(user_params.merge(memberships_attributes: memberships))
      end

    rescue ActiveRecord::RecordInvalid
      logger.info("User update unexpectedly failed. Rolling back transaction.")
    end

    def memberships
      supported_org_ids = (params[:user][:supported_organization_ids] || []).reject(&:empty?)
      memberships = supported_org_ids.map { |so| { user_id: @user.id, vita_partner_id: so, role: "lead"} }
      memberships.push({user_id: @user.id, vita_partner_id: params[:user][:vita_partner_id], role: "member"}) if params[:user][:vita_partner_id].present?
      memberships
    end

    def authorize_vita_partner_updates
      changing_vita_partner_ids = [params[:user][:vita_partner_id], params[:user][:supported_organization_ids]].flatten.select(&:present?)
      changing_vita_partner_ids.each { |id| authorize!(:manage, @vita_partners.find(id)) }
    end

    def user_params
      params.require(:user).permit(
          *(:is_admin if current_user.is_admin?),
          :timezone,
          )
    end
  end
end
