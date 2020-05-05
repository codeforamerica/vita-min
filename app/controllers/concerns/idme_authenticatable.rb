module IdmeAuthenticatable
  def set_omniauth_state
    state = SecureRandom.hex(24)
    session["omniauth.state"] = state
    state
  end

  def idme_authorize(**callback_params)
    idme_request(endpoint: "authorize", callback_params: callback_params)
  end

  def idme_logout(**callback_params)
    idme_request(endpoint: "logout", callback_params: callback_params)
  end

  def idme_request(endpoint:, callback_params: {})
    redirect_uri = URI.join(request.base_url, user_idme_omniauth_callback_path)
    redirect_uri += "?" + CGI.unescape(callback_params.to_query) if callback_params.present?

    logout_params = {
      state: set_omniauth_state,
      redirect_uri: redirect_uri,
      client_id: Rails.application.credentials.dig(:idme, :client_id),
    }

    if endpoint == "authorize"
      logout_params.merge!({
        scope: idme_scope,
        response_type: "code",
        op: "signup",
      })
    end

    URI::HTTPS.build(
      host: api_domain,
      path: "/oauth/#{endpoint}",
      query: URI.encode_www_form(logout_params)
    ).to_s
  end

  def idme_scope
    Rails.env.production? ? "identity" : "ial2"
  end

  def api_domain
    Rails.env.production? ? "api.id.me" : "api.idmelabs.com"
  end
end