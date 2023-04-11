module Hub
  module Users
    class StrongPasswordsController < ApplicationController
      before_action :redirect_away_if_needed

      layout "hub"

      def edit; end

      def update
        user = current_user
        user.assign_attributes(user_params)
        user.high_quality_password_as_of = DateTime.now

        if user.save
          bypass_sign_in(user) # Devise signs out after a password change, don't do that
          user.after_database_authentication
          return redirect_to after_sign_in_path_for(user)
        end

        render :edit
      end

      private

      def user_params
        params.require(:user).permit(:password, :password_confirmation).merge(high_quality_password_as_of: DateTime.now)
      end

      private

      def redirect_away_if_needed
        return redirect_to new_user_session_path if current_user.nil?
        return redirect_to after_sign_in_path_for(current_user) if (current_user.high_quality_password_as_of.present? || current_user.admin?)
      end
    end
  end
end
