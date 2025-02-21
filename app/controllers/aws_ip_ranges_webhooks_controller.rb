class AwsIpRangesWebhooksController < ApplicationController

  def update_aws_ip_ranges
    RemoteIpTrustedProxiesService.configure_trusted_proxies(RemoteIpTrustedProxiesService.load_current_aws_ip_ranges)
    puts "LOGGING AWS SNS SUBSCRIPTION CONFIRMATION FOR UPDATE_AWS_IP_RANGES WEBHOOK"
    puts params
    head :ok
  end

end