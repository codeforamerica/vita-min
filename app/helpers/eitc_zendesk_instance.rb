class EitcZendeskInstance
  DOMAIN = "eitc"

  # online intake group ids
  ALL_EITC_GROUP_IDS = [
    ONLINE_INTAKE_GWISR = "360008424134",
    ONLINE_INTAKE_UWBA = "360009415834",
    ONLINE_INTAKE_THC = "360009415854",
    ONLINE_INTAKE_WORKING_FAMILIES = "360009220253",
    ONLINE_INTAKE_UW_KING_COUNTY = "360009173713",
    ONLINE_INTAKE_UW_VIRGINIA = "360009267673",
    ONLINE_INTAKE_UW_CENTRAL_OHIO = "360009440374",
    ONLINE_INTAKE_IA_SC = "360009341873",
    ONLINE_INTAKE_IA_AL = "360009341853",
    ONLINE_INTAKE_FC = "360009397734",
  ].freeze

  # online intake source parameter to group
  ORGANIZATION_SOURCE_PARAMETERS = {
    uwkc: ONLINE_INTAKE_UW_KING_COUNTY,
    uwvp: ONLINE_INTAKE_UW_VIRGINIA,
    cwf: ONLINE_INTAKE_WORKING_FAMILIES,
    ia: ONLINE_INTAKE_IA_AL,
    goodwillsr: ONLINE_INTAKE_GWISR,
    fc: ONLINE_INTAKE_FC,
    uwco: ONLINE_INTAKE_UW_CENTRAL_OHIO,
  }.freeze

  # states for intake groups
  ONLINE_INTAKE_THC_STATES = %w(co sd tx wy ks nm ne).freeze
  ONLINE_INTAKE_UWBA_STATES = %w(ca ak fl nv).freeze
  ONLINE_INTAKE_GWISR_STATES = %w(ga al).freeze
  ONLINE_INTAKE_UW_KING_COUNTY_STATES = %w(wa).freeze
  ONLINE_INTAKE_WORKING_FAMILIES_STATES = %w(pa).freeze
  ONLINE_INTAKE_IA_SC_STATES = %w(sc).freeze
  ONLINE_INTAKE_IA_AL_STATES = %w(tn).freeze

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

  # Digital Intake Status value tags
  INTAKE_STATUS_IN_PROGRESS = "1._new_online_submission"
  INTAKE_STATUS_GATHERING_DOCUMENTS = "online_intake_gathering_documents"
  INTAKE_STATUS_READY_FOR_REVIEW = "online_intake_ready_for_review"
  INTAKE_STATUS_IN_REVIEW = "online_intake_in_review"
  INTAKE_STATUS_READY_FOR_INTAKE_INTERVIEW = "online_intake_ready_for_intake_interview"
  INTAKE_STATUS_WAITING_FOR_INFO = "online_intake_waiting_for_info"
  INTAKE_STATUS_COMPLETE = "3._ready_for_prep"
  INTAKE_STATUS_NOT_FILING = "online_intake_not_filing"

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
