class TaxReturnStatus
  class << self
    private

    def determine_statuses_by_stage
      ## Returns a hash of statuses grouped by stage
      stages = {}
      statuses = STATUSES.except(:intake_before_consent)
      statuses.map do |status, _|
        stage = status.to_s.split("_")[0]
        stages[stage] = [] unless stages.key?(stage)
        stages[stage].push(status)
      end
      stages
    end

    def message_templates
      {
          intake_info_requested: "hub.status_macros.needs_more_information",
          prep_info_requested: "hub.status_macros.needs_more_information",
          review_info_requested: "hub.status_macros.needs_more_information",
          review_ready_for_qr: "hub.status_macros.ready_for_qr",
          review_signature_requested: "hub.status_macros.signature_requested",
          file_accepted: "hub.status_macros.accepted"
      }
    end
  end
  # If we ever need to add statuses between these numbers, we can multiply these by 100, do a data migration, and
  # then insert a value in between.
  #
  # The first word of each status name is treated as a "stage" when grouping these in the interface.
  STATUSES = {
      intake_before_consent: 100, intake_in_progress: 101, intake_ready: 102, intake_reviewing: 103, intake_ready_for_call: 104, intake_info_requested: 105,

      prep_ready_for_prep: 201, prep_preparing: 202, prep_info_requested: 203,

      review_ready_for_qr: 301, review_reviewing: 302, review_ready_for_call: 303, review_signature_requested: 304, review_info_requested: 305,

      file_ready_to_file: 401, file_efiled: 402, file_mailed: 403, file_rejected: 404, file_accepted: 405, file_not_filing: 406
  }.freeze

  EXCLUDED_STATUSES = [:intake_before_consent, :intake_in_progress, :file_accepted, :file_not_filing].freeze
  STATUS_KEYS_INCLUDED_IN_CAPACITY = STATUSES.keys - EXCLUDED_STATUSES.freeze
  STATUSES_BY_STAGE = determine_statuses_by_stage.freeze
  STAGES = STATUSES_BY_STAGE.keys.freeze

  def self.message_template_for(status, locale = "en")
    message_templates[status.to_sym] ? I18n.t(message_templates[status.to_sym], locale: locale) : ""
  end
end