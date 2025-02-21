class ConfigureTrustedProxiesJob < ApplicationJob

  def perform
    uri = URI.parse(
      Rails.application.routes.url_helpers.url_for(
        { host: MultiTenantService.gyr.host,
          controller: 'aws_ip_ranges_webhooks',
          action: 'update_aws_ip_ranges' }
      ))
    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = uri.instance_of? URI::HTTPS
    request = Net::HTTP::Get.new(uri.path)
    http.request(request)
  end

  def priority
    PRIORITY_MEDIUM
  end
end