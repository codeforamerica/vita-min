class EitcZendeskInstance
  DOMAIN = "eitc"

  # online intake group ids
  ONLINE_INTAKE_GWISR = "360008424134"
  ONLINE_INTAKE_THC_UWBA = "360008424114"
  ONLINE_INTAKE_UW_TUCSON = "360008416353"
  ONLINE_INTAKE_WORKING_FAMILIES = "360009220253"
  ONLINE_INTAKE_UW_KING_COUNTY = "360009173713"

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
  LINKED_TICKET = "360033135434"
  NEEDS_RESPONSE = "360035388874"

  # Digital Intake Status value tags
  INTAKE_STATUS_IN_PROGRESS = "1._new_online_submission"
  INTAKE_STATUS_GATHERING_DOCUMENTS = "online_intake_gathering_documents"
  INTAKE_STATUS_READY_FOR_REVIEW = "online_intake_ready_for_review"
  INTAKE_STATUS_IN_REVIEW = "online_intake_in_review"
  INTAKE_STATUS_READY_FOR_INTAKE_INTERVIEW = "online_intake_ready_for_intake_interview"
  INTAKE_STATUS_WAITING_FOR_INFO = "online_intake_waiting_for_info"
  INTAKE_STATUS_COMPLETE = "3._ready_for_prep"
  INTAKE_STATUS_NOT_FILING = "online_intake_not_filing"

  def self.client
    ZendeskAPI::Client.new do |config|
      config.url = "https://#{DOMAIN}.zendesk.com/api/v2"
      config.username = Rails.application.credentials.dig(:zendesk, :eitc, :account_email)
      config.token = Rails.application.credentials.dig(:zendesk, :eitc, :api_key)
    end
  end
end
