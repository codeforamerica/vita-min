class Users::SessionsController < Devise::SessionsController
  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message! :notice, :signed_out if signed_out

    state = SecureRandom.hex(24)
    session["omniauth.state"] = state
    logout_params = {
      state: state,
      redirect_uri: URI.join(request.base_url, user_idme_omniauth_callback_path) + "?logout=success",
      client_id: Rails.application.credentials.dig(:idme, :client_id),
    }

    redirect_to idme_logout_request_uri(logout_params)
  end

  private

  def idme_logout_request_uri(params)
    URI::HTTPS.build(
      host: "api.idmelabs.com",
      path: "/oauth/logout",
      query: URI.encode_www_form(params)
    ).to_s
  end
end