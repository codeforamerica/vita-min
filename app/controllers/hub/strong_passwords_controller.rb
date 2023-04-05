module Hub
  class StrongPasswordsController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    before_action :set_minimum_password_length
    before_action :redirect_if_is_admin_user
    before_action :redirect_if_password_has_been_forcibly_reset

    layout "hub"

    def edit
      @user = current_user
    end

    def update
      @user = current_user
      @user.assign_attributes(user_params)
      @user.high_quality_password_as_of = DateTime.now

      if @user.save
        bypass_sign_in(@user) # Devise signs out after a password change, don't do that
        @user.after_database_authentication
        return redirect_to after_sign_in_path_for(@user)
      end

      render :edit
    end

    private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def set_minimum_password_length
      @minimum_password_length = User.PASSWORD_LENGTH.min
    end

    def redirect_if_is_admin_user
      redirect_to after_sign_in_path_for(current_user) if current_user.present? and current_user.admin?
    end

    def redirect_if_password_has_been_forcibly_reset
      redirect_to after_sign_in_path_for(current_user) if current_user.high_quality_password_as_of.present?
    end
  end
end
