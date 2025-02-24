class AwsIpRangesWebhooksController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def update_aws_ip_ranges
    RemoteIpTrustedProxiesService.configure_trusted_proxies(RemoteIpTrustedProxiesService.load_current_aws_ip_ranges)
    Rails.logger.info("LOGGING AWS SNS SUBSCRIPTION CONFIRMATION FOR UPDATE_AWS_IP_RANGES WEBHOOK: #{params}")
    head :ok
  end

end