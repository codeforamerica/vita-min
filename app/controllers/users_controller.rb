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
    @timezone_options = ActiveSupport::TimeZone.country_zones("us").map(&:name)
  end

  def update
    return render :edit unless @user.update(user_params)
    redirect_to edit_user_path(id: @user)
  end

  private

  def user_params
    params.require(:user).permit(:is_beta_tester, :vita_partner_id)
  end
end
