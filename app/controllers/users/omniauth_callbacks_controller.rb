class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    handle_auth("Google")
  end

  private

  def handle_auth(kind)
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.present?
      flash[:notice] = I18n.t('devise.omniauth_callbacks.success', kind: kind)
      sign_in_and_redirect @user, event: :authentication
    else
      Rails.logger.warn("Error during google_oauth2 callback: #{failure_message}") if failure_message.present?
      redirect_to(new_user_session_path,
                  alert: I18n.t("controllers.users.omniauth_callbacks_controller.no_such_account_or_use_form"))
    end
  end
end
