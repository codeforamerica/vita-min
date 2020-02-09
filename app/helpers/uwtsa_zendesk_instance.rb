class UwtsaZendeskInstance
  DOMAIN = "unitedwaytucson"

  def self.client
    ZendeskAPI::Client.new do |config|
      config.url = "https://#{DOMAIN}.zendesk.com/api/v2"
      config.username = Rails.application.credentials.dig(:zendesk, :uwtsa, :account_email)
      config.token = Rails.application.credentials.dig(:zendesk, :uwtsa, :api_key)
    end
  end
end