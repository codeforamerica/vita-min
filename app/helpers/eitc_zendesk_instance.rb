class EitcZendeskInstance
  DOMAIN = "eitc"
  # ZD "Professional" plan allows uploads up to 20MB
  MAXIMUM_UPLOAD_SIZE = 20000000

  # custom field id codes
  CERTIFICATION_LEVEL = "360028917234"
  INTAKE_SITE = "360028917374"
  STATE = "360028917614"
  INTAKE_STATUS = "360029025294"
  SIGNATURE_METHOD = "360029896814"
  HSA = "360031865033"
  LINKED_TICKET = "360033135434"
  NEEDS_RESPONSE = "360035388874"
  FILING_YEARS = "360037221113"
  COMMUNICATION_PREFERENCES = "360037409074"
  DOCUMENT_REQUEST_LINK = "360038257473"
  INTAKE_SOURCE = "360040933734"
  INTAKE_LANGUAGE = "360042599353"
  LINK_TO_CLIENT_DOCUMENTS = "360042211294"

  # Digital Intake Status value tags
  INTAKE_STATUS_UNSTARTED = ""
  INTAKE_STATUS_IN_PROGRESS = "1._new_online_submission"
  INTAKE_STATUS_GATHERING_DOCUMENTS = "online_intake_gathering_documents"
  INTAKE_STATUS_READY_FOR_REVIEW = "online_intake_ready_for_review"
  INTAKE_STATUS_IN_REVIEW = "online_intake_in_review"
  INTAKE_STATUS_READY_FOR_INTAKE_INTERVIEW = "online_intake_ready_for_intake_interview"
  INTAKE_STATUS_WAITING_FOR_INFO = "online_intake_waiting_for_info"
  INTAKE_STATUS_COMPLETE = "3._ready_for_prep"
  INTAKE_STATUS_NOT_FILING = "online_intake_not_filing"

  INTAKE_STATUS_LABELS = {
    INTAKE_STATUS_UNSTARTED => "Unstarted",
    INTAKE_STATUS_IN_PROGRESS => "In Progress",
    INTAKE_STATUS_GATHERING_DOCUMENTS => "Gathering Documents",
    INTAKE_STATUS_READY_FOR_REVIEW => "Ready For Review",
    INTAKE_STATUS_IN_REVIEW => "In Review",
    INTAKE_STATUS_READY_FOR_INTAKE_INTERVIEW => "Ready For Intake Interview",
    INTAKE_STATUS_WAITING_FOR_INFO => "Waiting For Info",
    INTAKE_STATUS_COMPLETE => "Complete",
    INTAKE_STATUS_NOT_FILING => "Not Filing",
}

  # Zendesk Ticket Return Statuses
  RETURN_STATUS_UNSTARTED = ""
  RETURN_STATUS_IN_PROGRESS = "1._in_progress"
  RETURN_STATUS_READY_FOR_QUALITY_REVIEW = "2._ready_for_quality_review"
  RETURN_STATUS_READY_FOR_SIGNATURE_ESIGN = "3a._ready_for_signature__e-sign"
  RETURN_STATUS_READY_FOR_SIGNATURE_PICKUP = "3b._ready_for_signature__pick-up"
  RETURN_STATUS_READY_FOR_EFILE = "4._ready_for_e-file"
  RETURN_STATUS_COMPLETED_RETURNS = "5._completed_returns"
  RETURN_STATUS_DO_NOT_FILE = "6._do_not_file"
  RETURN_STATUS_FOREIGN_STUDENT = "7._foreign_student"

  RETURN_STATUS_LABELS = {
    RETURN_STATUS_UNSTARTED => "Unstarted",
    RETURN_STATUS_IN_PROGRESS => "In Progress",
    RETURN_STATUS_READY_FOR_QUALITY_REVIEW => "Ready For Quality Review",
    RETURN_STATUS_READY_FOR_SIGNATURE_ESIGN => "Ready For Signature E-Sign",
    RETURN_STATUS_READY_FOR_SIGNATURE_PICKUP	=> "Ready For Signature Pick-Up",
    RETURN_STATUS_READY_FOR_EFILE => "Ready For E-File",
    RETURN_STATUS_COMPLETED_RETURNS => "Completed Returns",
    RETURN_STATUS_DO_NOT_FILE => "Do Not File",
    RETURN_STATUS_FOREIGN_STUDENT => "Foreign Student",
  }

  # partner group ids for drop offs
  TAX_HELP_COLORADO = "360007047214"
  GOODWILL_SOUTHERN_RIVERS = "360007941454"
  UNITED_WAY_BAY_AREA = "360007047234"

  def self.client
    ZendeskAPI::Client.new do |config|
      config.url = "https://#{DOMAIN}.zendesk.com/api/v2"
      config.username = Rails.application.credentials.dig(:zendesk, :eitc, :account_email)
      config.token = Rails.application.credentials.dig(:zendesk, :eitc, :api_key)
    end
  end
end
