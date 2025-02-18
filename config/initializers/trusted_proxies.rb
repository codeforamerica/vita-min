# These need to happen after initialization because classes haven't been loaded yet
Rails.application.server do
  Rails.application.configure do
    # Load the file from the repo to ensure that we have some recent IPs loaded, then attempt to load the up-to-date file from AWS
    RemoteIpTrustedProxiesService.configure_trusted_proxies(RemoteIpTrustedProxiesService.load_current_aws_ip_ranges)

    http = Net::HTTP.new(server_url.host, server_url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(server_url.request_uri)
    response = http.request(request)

  end
end
