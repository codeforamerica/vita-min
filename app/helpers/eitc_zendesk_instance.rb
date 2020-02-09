class EitcZendeskInstance
  DOMAIN = "eitc"

  # online intake group ids
  ONLINE_INTAKE_GWISR = "360008424134"
  ONLINE_INTAKE_THC_UWBA = "360008424114"
  ONLINE_INTAKE_UW_TUCSON = "360008416353"

  # partner group ids
  TAX_HELP_COLORADO = "360007047214"
  GOODWILL_SOUTHERN_RIVERS = "360007941454"
  UNITED_WAY_BAY_AREA = "360007047234"

  # custom field id codes
  CERTIFICATION_LEVEL = "360028917234"
  INTAKE_SITE = "360028917374"
  STATE = "360028917614"
  INTAKE_STATUS = "360029025294"
  SIGNATURE_METHOD = "360029896814"
  HSA = "360031865033"

  def self.client
    ZendeskAPI::Client.new do |config|
      config.url = "https://#{DOMAIN}.zendesk.com/api/v2"
      config.username = Rails.application.credentials.dig(:zendesk, :eitc, :account_email)
      config.token = Rails.application.credentials.dig(:zendesk, :eitc, :api_key)
    end
  end
end