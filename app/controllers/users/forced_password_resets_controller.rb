module Users
  class ForcedPasswordResetsController < ApplicationController
    before_action :set_minimum_password_length

    layout "application"

    def edit
      @user = current_user
    end

    def update
      @user = current_user

      if @user.valid_password?(user_params[:password])
        @user.errors.add(:password, "Your new password should be different than your old password.")
      else
        @user.assign_attributes(user_params)
        @user.forced_password_reset_at = Time.current

        if @user.save
          bypass_sign_in(@user) # Devise signs out after a password change, don't do that
          @user.after_database_authentication
        end
      end

      respond_with @user, location: cbo_analytics_path(@user.cbo)
    end

    private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def set_minimum_password_length
      @minimum_password_length = User.password_length.min
    end
  end
end
