class TrustedProxiesService

  def load_cached_trusted_proxies

  end

  def load_latest_trusted_proxies
    trusted_proxies = if current_or_cached == :current
                        RemoteIpTrustedProxiesService.load_current_aws_ip_ranges
                      elsif current_or_cached == :cached
                        RemoteIpTrustedProxiesService.load_cached_aws_ip_ranges
                      end
    RemoteIpTrustedProxiesService.configure_trusted_proxies(trusted_proxies)
  end

end