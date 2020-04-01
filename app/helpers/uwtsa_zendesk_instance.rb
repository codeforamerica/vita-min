class UwtsaZendeskInstance
  DOMAIN = "unitedwaytucson"

  # custom field id codes
  CERTIFICATION_LEVEL = "114101964473"
  INTAKE_SITE = "360000711634"
  STATE = "360035942194"
  INTAKE_STATUS = "360033377693"
  SIGNATURE_METHOD = "360035942394"
  HSA = "360034012514"
  LINKED_TICKET = "360035942494"
  NEEDS_RESPONSE = "360035847233"
  FILING_YEARS = "360037476894"
  COMMUNICATION_PREFERENCES = "360037477054"

  # Digital Intake Status value tags
  INTAKE_STATUS_IN_PROGRESS = "1._new_online_submission"
  INTAKE_STATUS_GATHERING_DOCUMENTS = "2._ready_for_intake_interview"
  INTAKE_STATUS_READY_FOR_REVIEW = "3._intake_complete_-_ready_for_prep"
  INTAKE_STATUS_IN_REVIEW = "4._in_review"
  INTAKE_STATUS_READY_FOR_INTAKE_INTERVIEW = "5._ready_for_intake_interview"
  INTAKE_STATUS_WAITING_FOR_INFO = "6._waiting_for_more_info"
  INTAKE_STATUS_COMPLETE = "7._complete"
  INTAKE_STATUS_NOT_FILING = "8._not_filing"

  def self.client
    ZendeskAPI::Client.new do |config|
      config.url = "https://#{DOMAIN}.zendesk.com/api/v2"
      config.username = Rails.application.credentials.dig(:zendesk, :uwtsa, :account_email)
      config.token = Rails.application.credentials.dig(:zendesk, :uwtsa, :api_key)
    end
  end
end
