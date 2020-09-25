class UsersController < ApplicationController
  include AccessControllable

  before_action :require_sign_in
  before_action :require_beta_tester
  before_action :get_user, only: [:edit, :update]

  layout "admin"

  def profile
  end

  def index
    @users = User.includes(:vita_partner)
  end

  def edit
  end

  def update
    return render :edit unless @user.update(user_params)
    redirect_to edit_user_path(id: @user)
  end

  private

  def get_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:is_beta_tester, :vita_partner_id)
  end
end
