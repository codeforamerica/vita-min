# Only load trusted proxies on server processes
Rails.application.server do
  # Wait until after initialization so that routes have been loaded before we try to hit the update_aws_ip_ranges webhook
  Rails.application.config.after_initialize do
    # Load the file from the repo to ensure that we have some recent IPs loaded before serving any traffic
    RemoteIpTrustedProxiesService.configure_trusted_proxies(RemoteIpTrustedProxiesService.load_cached_aws_ip_ranges)
    # Then attempt to load the up-to-date file from AWS asynchronously
    ConfigureTrustedProxiesJob.perform_later
  end
end
