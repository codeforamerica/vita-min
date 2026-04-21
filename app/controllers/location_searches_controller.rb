require "net/http"

class LocationSearchesController < ApplicationController
  ICON_ALLOWED_CONTENT_TYPES = %w[image/png image/jpeg image/svg+xml image/webp].freeze
  ICON_MAX_BYTES = 1.megabyte

  def new
    @locations = ScrapeVitaProvidersService.new().import
  end

  # Server-side proxy that lets the "Find a location" page render partner-hosted provider
  # icons while keeping analytics off the partner's domain. The URL is provided by the
  # client, so we limit the response size and restrict the content-type to common image
  # formats before streaming the bytes back to the browser.
  def provider_icon_preview
    uri = URI.parse(params[:icon_url].to_s)
    return head :bad_request unless %w[http https].include?(uri.scheme)

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 3, read_timeout: 5) do |http|
      http.request(Net::HTTP::Get.new(uri.request_uri))
    end

    content_type = response["content-type"].to_s.split(";").first
    return head :unsupported_media_type unless ICON_ALLOWED_CONTENT_TYPES.include?(content_type)

    body = response.body.to_s
    return head :payload_too_large if body.bytesize > ICON_MAX_BYTES

    send_data(body, type: content_type, disposition: "inline")
  rescue URI::InvalidURIError, SocketError, Net::OpenTimeout, Net::ReadTimeout
    head :bad_gateway
  end
end
