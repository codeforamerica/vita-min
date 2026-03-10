CONTENTFUL_CLIENT = Contentful::Client.new(
  space: Rails.application.credentials.dig(:contentful, :space_id),
  access_token: Rails.application.credentials.dig(:contentful, :delivery_access_token)
)

# optional preview client
CONTENTFUL_PREVIEW_CLIENT = Contentful::Client.new(
  space: Rails.application.credentials.dig(:contentful, :space_id),
  access_token: Rails.application.credentials.dig(:contentful, :preview_access_token),
  api_url: 'preview.contentful.com'
)