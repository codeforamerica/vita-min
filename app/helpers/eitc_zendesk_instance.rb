class EitcZendeskInstance
  DOMAIN = "eitc"
  # ZD "Professional" plan allows uploads up to 20MB
  MAXIMUM_UPLOAD_SIZE = 20000000

  # online intake group ids
  ALL_EITC_GROUP_IDS = [
    ONLINE_INTAKE_GWISR = "360008424134",
    ONLINE_INTAKE_UWBA = "360009415834",
    ONLINE_INTAKE_THC = "360009415854",
    ONLINE_INTAKE_WORKING_FAMILIES = "360009220253",
    ONLINE_INTAKE_UW_KING_COUNTY = "360009173713",
    ONLINE_INTAKE_UW_VIRGINIA = "360009267673",
    ONLINE_INTAKE_UW_CENTRAL_OHIO = "360009440374",
    ONLINE_INTAKE_UW_FRESNO_MADERA = "360009708233",
    ONLINE_INTAKE_IA_AL = "360009341853", # Impact America Alabama
    ONLINE_INTAKE_IA_SC = "360009341873", # Impact America South Carolina
    ONLINE_INTAKE_IA_TN = "360009830214", # Impact America Tennessee
    ONLINE_INTAKE_FC = "360009397734",     # Foundation Communities
    ONLINE_INTAKE_NV_FTC = "360009537374", # Nevada Free Tax Coalition
    ONLINE_INTAKE_UW_TSA = "360009581934", # Nevada Free Tax Coalition
    ONLINE_INTAKE_UWCCR = "360009708193", # United Way California Capital Region
    ONLINE_INTAKE_UWCA_KOREATOWN = "360010314594", # Koreatown Youth Community Center (UWCA)
    ONLINE_INTAKE_BRANCHES_FL = "360009704234", # Branches (FL)
    ONLINE_INTAKE_HU_FL = "360009704314", # Hispanic Unity (FL)
    ONLINE_INTAKE_CATALYST = "360009704354", # Catalyst Miami
    ONLINE_INTAKE_REFUND_DAY = "360009657014", # Refund Day (FL)
    ONLINE_INTAKE_TH_NM = "360009807434", # Tax Help New Mexico
    ONLINE_INTAKE_UW_CRPA = "360009994193", # United Way Capital Region (PA)
    ONLINE_INTAKE_UW_GREENVILLE = "360010052433", # United Way of Greenville County
    ONLINE_INTAKE_UW_NEWARK = "360010163193", # United Way of Greater Newark
    ONLINE_INTAKE_URBAN_UPBOUND = "360010243314", # Urban Upbound (NY)
  ].freeze

  GROUP_ID_TO_STATE_LIST_MAPPING = {
    ONLINE_INTAKE_UW_CENTRAL_OHIO => %w(oh).freeze,
    ONLINE_INTAKE_UW_KING_COUNTY => %w(wa).freeze,
    ONLINE_INTAKE_IA_SC => %w(sc).freeze,
    ONLINE_INTAKE_IA_TN => %w(tn ar ms).freeze,
    ONLINE_INTAKE_NV_FTC => %w(nv).freeze,
    ONLINE_INTAKE_FC => %w(tx).freeze,
    ONLINE_INTAKE_THC => %w(co sd wy ks ne).freeze,
    ONLINE_INTAKE_UWBA => %w(ca ak).freeze,
    ONLINE_INTAKE_GWISR => %w(ga al).freeze,
    ONLINE_INTAKE_WORKING_FAMILIES => %w(pa nj).freeze,
    ONLINE_INTAKE_UW_VIRGINIA => %w(va).freeze,
    ONLINE_INTAKE_REFUND_DAY => %w(fl).freeze,
    ONLINE_INTAKE_TH_NM => %w(nm).freeze,
  }.freeze

  # online intake source parameter to group
  ORGANIZATION_SOURCE_PARAMETERS = {
    uwkc: ONLINE_INTAKE_UW_KING_COUNTY,
    uwvp: ONLINE_INTAKE_UW_VIRGINIA,
    cwf: ONLINE_INTAKE_WORKING_FAMILIES,
    ia: ONLINE_INTAKE_IA_AL,
    goodwillsr: ONLINE_INTAKE_GWISR,
    fc: ONLINE_INTAKE_FC,
    uwco: ONLINE_INTAKE_UW_CENTRAL_OHIO,
    uwccr: ONLINE_INTAKE_UWCCR,
    "refundday-b" => ONLINE_INTAKE_BRANCHES_FL,
    branchesfl: ONLINE_INTAKE_BRANCHES_FL,
    "refundday-h" => ONLINE_INTAKE_HU_FL,
    hispanicunity: ONLINE_INTAKE_HU_FL,
    uwfm: ONLINE_INTAKE_UW_FRESNO_MADERA,
    uwcrpa: ONLINE_INTAKE_UW_CRPA,
    uwgc: ONLINE_INTAKE_UW_GREENVILLE,
    catalyst: ONLINE_INTAKE_CATALYST,
    "refundday-c" => ONLINE_INTAKE_CATALYST,
    uwgn: ONLINE_INTAKE_UW_NEWARK,
    uuny: ONLINE_INTAKE_URBAN_UPBOUND,
    kycc: ONLINE_INTAKE_UWCA_KOREATOWN,
  }.freeze


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
