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
      flash[:alert] = I18n.t('devise.omniauth_callbacks.failure', kind: kind, reason: failure_message)
      session['devise.auth_data'] = request.env['omniauth.auth'].except('extra')
      redirect_to new_user_session_path, alert: I18n.t("controllers.users.omniauth_callbacks_controller.use_form_to_sign_in")
    end
  end
end
