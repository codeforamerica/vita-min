class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def zendesk
    user = User.from_zendesk_oauth(request.env["omniauth.auth"])
    unless user.persisted?
      user.save
    end
    auth_data = request.env["omniauth.auth"]
    after_login_path = session.delete("after_zendesk_login")

    # this will clear the session
    sign_in user, event: :authentication

    # store this access token in the session so that it expires with the session
    # we will use this token to retrieve Zendesk information on behalf of the user
    session[:zendesk_access_token] = auth_data.credentials.token

    return redirect_to after_login_path if after_login_path.present?

    redirect_to root_path, notice: "Signed in as #{user.name}, #{user.email}"
  end

  def failure
    error_type = request.env["omniauth.error.type"]
    error = request.env["omniauth.error"]
    if error_type == :access_denied
      # the user did not grant permission to view their info
      redirect_to identity_needed_path
    else
      logger.error("#{error}, #{error_type}")
      raise error
    end
  end
end
