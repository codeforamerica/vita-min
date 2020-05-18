class ZendeskController < ApplicationController
  before_action :require_zendesk_authentication, except: [:sign_in, :authorize_zendesk, :zendesk_callback]

  def sign_in
  end

  def ticket
    @user = zendesk_client.current_user
    @zendesk_ticket_id = params[:ticket_id]
    @ticket = zendesk_client.tickets.find(id: @zendesk_ticket_id)
    raise ActionController::RoutingError.new("Not Found") unless @ticket.present?
    @intakes = Intake.where(intake_ticket_id: @zendesk_ticket_id)
  end

  def authorize_zendesk
    state = SecureRandom.hex(24)
    redirect_uri = zendesk_callback_url

    authorize_params = {
      response_type: "code",
      redirect_uri: redirect_uri,
      client_id: EnvironmentCredentials.dig(:zendesk_oauth, :client_id),
      scope: "read",
      state: state,
    }

    full_url = URI::HTTPS.build(
      host: "eitc.zendesk.com",
      path: "/oauth/authorizations/new",
      query: URI.encode_www_form(authorize_params)
    ).to_s

    session["zendesk_oauth.state"] = state

    redirect_to full_url
  end

  def zendesk_callback
    error = params[:error]
    error_description = params[:error_description]
    raise error_description if error_description.present?

    state = session["zendesk_oauth.state"]
    raise "OAuth CSRF error" unless params[:state] == state

    # get the token
    code = params[:code]
    url = URI::HTTPS.build(
      host: "eitc.zendesk.com",
      path: "/oauth/tokens"
    )
    response = Net::HTTP.post_form(url, {
      grant_type: "authorization_code",
      code: code,
      client_id: EnvironmentCredentials.dig(:zendesk_oauth, :client_id),
      client_secret: EnvironmentCredentials.dig(:zendesk_oauth, :client_secret),
      redirect_uri: zendesk_callback_url,
      scope: "read"
    })
    data = JSON.parse(response.body)
    #set_access_token data["access_token"]

    puts "\n\nAccess Token: #{access_token}\n\n"

    user = zendesk_client.current_user
    redirect_to root_path, notice: "signed in as #{user.name}"
  end

  private

  def require_zendesk_authentication
    puts "checking for zendesk login, Provider: #{current_user&.provider}"
    unless current_user&.provider == "zendesk"
      puts "\n\nNot authenticated, saving #{request.path} in session for later\n\n"
      session[:after_zendesk_login] = request.path
      redirect_to zendesk_sign_in_path
    end
  end

  def oauth_client
    @_oauth_client ||= OAuth2::Client.new(
      EnvironmentCredentials.dig(:zendesk_oauth, :client_id),
      EnvironmentCredentials.dig(:zendesk_oauth, :client_secret),
       site: "https://eitc.zendesk.com",
       token_url: "/oauth/tokens",
       authorize_url: "/oauth/authorizations/new"
    )
  end

  def zendesk_client
    @_zendesk_client ||= ZendeskAPI::Client.new do |client|
      client.access_token = access_token
      client.url = "https://eitc.zendesk.com/api/v2"
    end
  end

  def access_token
    @access_token ||= session[:zendesk_access_token]
  end
end
