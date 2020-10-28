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

    redirect_to edit_user_path(id: @user)
  end

  private

  def user_params
    out = params.require(:user).permit(
      *(:is_admin if current_user.is_admin?),
      :is_beta_tester,
      :vita_partner_id,
      :timezone,
      **(current_user.is_admin ? {supported_organization_ids: []} : {}),
    )
    out[:supported_organization_ids] = out[:supported_organization_ids].filter { |x| x.present? }
    out
  end
end
