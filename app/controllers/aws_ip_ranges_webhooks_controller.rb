class AwsIpRangesWebhooksController < ApplicationController

  def update_aws_ip_ranges

    puts "EHLLO WE ARE IN THE CONTROLLER"

    RemoteIpTrustedProxiesService.configure_trusted_proxies(RemoteIpTrustedProxiesService.load_current_aws_ip_ranges)

    render text: "HELLO WE DID THE THING"
  end

end