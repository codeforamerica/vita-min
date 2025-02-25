class RemoteIpTrustedProxiesService
  class << self

    def configure_trusted_proxies(trusted_proxy_ip_ranges)
      return unless trusted_proxy_ip_ranges.present? && trusted_proxy_ip_ranges.count > 1
      # Telling ActionDispatch about AWS' IP ranges prevents their load balancers etc from being interpreted as the client IP
      Rails.application.configure do
        config.action_dispatch.trusted_proxies = ActionDispatch::RemoteIp::TRUSTED_PROXIES + trusted_proxy_ip_ranges
      end
    end

    def load_current_aws_ip_ranges
      url = "https://ip-ranges.amazonaws.com/ip-ranges.json"
      parse_aws_ip_ranges(Net::HTTP.get_response(URI(url)).body)
    end

    def load_cached_aws_ip_ranges
      path = "config/aws_ip_ranges.json"
      parse_aws_ip_ranges(File.read(path))
    end

    private

    def parse_aws_ip_ranges(aws_ip_ranges_json)
      ipv4_strings = JSON.parse(aws_ip_ranges_json)["prefixes"].map { |ip_json| ip_json["ip_prefix"] }
      ipv6_strings = JSON.parse(aws_ip_ranges_json)["ipv6_prefixes"].map { |ip_json| ip_json["ipv6_prefix"] }
      (ipv4_strings + ipv6_strings).map { |ip_string| IPAddr.new(ip_string) }
    end

  end
end