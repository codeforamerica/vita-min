class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def zendesk
    user = User.from_zendesk_oauth(request.env["omniauth.auth"])

    # retrieve any useful session data before signing in
    after_login_path = session.delete("after_login_path")

    # this will clear the session
    sign_in user, event: :authentication

    return redirect_to after_login_path if after_login_path.present?

    # TODO: i18n
    redirect_to root_path, notice: "Signed in as #{user.name}, #{user.email}"
  end

  def failure
    error_type = request.env["omniauth.error.type"]
    error = request.env["omniauth.error"]
    if error_type == :access_denied
      # the user did not grant permission to view their info
      # TODO: i18n
      redirect_to root_path, alert: "We were not able to verify your Zendesk account."
    else
      raise error
    end
  end
end
