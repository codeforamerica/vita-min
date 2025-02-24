# Only load trusted proxies on server processes
Rails.application.server do
  # These need to happen after initialization because classes haven't been loaded yet
  Rails.application.config.after_initialize do
    # Load the file from the repo to ensure that we have some recent IPs loaded, then attempt to load the up-to-date file from AWS
    RemoteIpTrustedProxiesService.configure_trusted_proxies(RemoteIpTrustedProxiesService.load_cached_aws_ip_ranges)
    ConfigureTrustedProxiesJob.perform_later
  end
end
