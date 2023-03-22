module Hub
  class ForcedPasswordResetsController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    before_action :set_minimum_password_length
    before_action :redirect_if_is_admin_user

    layout "hub"

    def edit
      @user = current_user
    end

    def update
      @user = current_user

      if @user.valid_password?(user_params[:password])
        @user.errors.add(:password, I18n.t("errors.attributes.password.must_be_different"))
      elsif user_params[:password] != user_params[:password_confirmation]
        @user.errors.add(:password, I18n.t("errors.attributes.password.not_matching"))
      else
        @user.assign_attributes(user_params)
        @user.forced_password_reset_at = DateTime.now

        if @user.save
          bypass_sign_in(@user) # Devise signs out after a password change, don't do that
          @user.after_database_authentication
          return redirect_to after_sign_in_path_for(@user)
        end
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
  end
end
