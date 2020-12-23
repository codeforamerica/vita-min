class Users::SessionsController < Devise::SessionsController
  layout "admin"

  def new
    super do |user|
      # When warden and devise threw an authentication error (invalid password)
      # They don't respect the locale param
      # This allows us to detect devise's authentication error, enforce internationalization,
      # and move the error message onto the user object in order to treat it like a validation error
      if flash[:alert] == "Invalid email or password" # The default devise english failure message
        flash.delete :alert
        user.errors[:password] << I18n.t("controllers.users.sessions_controller.new.invalid_email_or_password")
      end
    end
  end

  def create
    @after_login_path = session.delete("after_login_path")
    super
  end
end
