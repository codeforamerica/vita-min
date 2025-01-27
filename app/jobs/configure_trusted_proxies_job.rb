class ConfigureTrustedProxiesJob < ApplicationJob
  def perform(current_or_cached:)
    trusted_proxies = if current_or_cached == :current
                        RemoteIpTrustedProxiesService.load_current_aws_ip_ranges
                      elsif current_or_cached == :cached
                        RemoteIpTrustedProxiesService.load_cached_aws_ip_ranges
                      end
    RemoteIpTrustedProxiesService.configure_trusted_proxies(trusted_proxies)
  end

  def priority
    PRIORITY_MEDIUM
  end
end