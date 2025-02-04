namespace :trusted_proxies do
  desc "Downloads AWS' IP ranges and loads them into ActionDispatch::RemoteIp's trusted_proxies"
  task configure_trusted_proxies_to_current_aws_ip_ranges: [:environment] do
    ConfigureTrustedProxiesJob.perform_now(current_or_cached: :current)
  end
end
