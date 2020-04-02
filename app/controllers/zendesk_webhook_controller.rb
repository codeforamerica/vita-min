class ZendeskWebhookController < ApplicationController
  skip_before_action :verify_authenticity_token, :set_visitor_id, :set_source, :set_referrer, :set_utm_state
  before_action :authenticate

  def incoming
    head :ok if params[:zendesk_webhook].present?
  end

  private

  def authenticate
    authenticate_or_request_with_http_basic do |name, password|
      expected_name = EnvironmentCredentials.dig(:zendesk_webhook_auth, :name)
      expected_password = EnvironmentCredentials.dig(:zendesk_webhook_auth, :password)
      ActiveSupport::SecurityUtils.secure_compare(name, expected_name) &&
        ActiveSupport::SecurityUtils.secure_compare(password, expected_password)
    end
  end
end
