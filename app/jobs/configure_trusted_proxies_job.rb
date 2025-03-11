class ConfigureTrustedProxiesJob < ApplicationJob

  def perform
    uri = URI.parse(
      Rails.application.routes.url_helpers.url_for(
        { host: MultiTenantService.gyr.host,
          controller: 'aws_ip_ranges_webhooks',
          action: 'update_aws_ip_ranges' }
      ))
    Net::HTTP.get_response(uri)
  end

  def priority
    PRIORITY_LOW
  end
end