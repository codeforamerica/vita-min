class Users::SessionsController < Devise::SessionsController
  layout "hub"

  def new
    super do |user|
      # When warden and devise threw an authentication error (invalid password)
      # They don't respect the locale param
      # This allows us to detect devise's authentication error, enforce internationalization,
      # and move the error message onto the user object in order to treat it like a validation error
      if flash[:alert] == "Invalid email or password" # The default devise english failure message
        flash.delete :alert
        user.errors.add(:password, I18n.t("controllers.users.sessions_controller.new.invalid_email_or_password"))
      end
    end
  end

  def create
    @after_login_path = session.delete("after_login_path")

    super do |user|
      if !user.admin? and user.forced_password_reset_at.nil?
        if PasswordIntegrityValidator.is_strong_enough?(params[:user][:password], user)
          user.update!(forced_password_reset_at: DateTime.now)
        else
          user.instance_variable_set(:@needs_to_redirect_to_force_password_change, true)
        end
      end

      user
    end
  end

  rescue_from 'ArgumentError' do |error|
    respond_to do |format|
      format.any do
        if error.message == "string contains null byte"
          head 400
        else
          raise
        end
      end
    end
  end
end
