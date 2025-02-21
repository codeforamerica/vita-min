class AwsIpRangesWebhooksController < ApplicationController

  def update_aws_ip_ranges
    RemoteIpTrustedProxiesService.configure_trusted_proxies(RemoteIpTrustedProxiesService.load_current_aws_ip_ranges)
    head :ok
  end

end