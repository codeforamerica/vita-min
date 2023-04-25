class Users::SessionsController < Devise::SessionsController
  layout "hub"
  prepend_before_action :redirect_if_requires_google_login, except: [:new]

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
    super
  end

  def redirect_if_requires_google_login
    return unless Rails.configuration.google_login_enabled
    return unless params['user'].present?

    if User.google_login_domain?(params['user']['email'])
      flash[:alert] = "You must sign through the admin sign in link below"
      return redirect_to new_user_session_path
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
