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
          intake_more_info: "hub.status_macros.needs_more_information",
          prep_more_info: "hub.status_macros.needs_more_information",
          review_more_info: "hub.status_macros.needs_more_information",
          prep_ready_for_review: "hub.status_macros.ready_for_qr",
          filed_accepted: "hub.status_macros.accepted"
      }
    end
  end
  # If we ever need to add statuses between these numbers, we can multiply these by 100, do a data migration, and
  # then insert a value in between.
  #
  # The first word of each status name is treated as a "stage" when grouping these in the interface.
  STATUSES = {
      intake_before_consent: 100, intake_in_progress: 101, intake_open: 102, intake_review: 103, intake_more_info: 104, intake_info_requested: 105, intake_needs_assignment: 106,
      prep_ready_for_call: 201, prep_more_info: 202, prep_preparing: 203, prep_ready_for_review: 204,
      review_in_review: 301, review_complete_signature_requested: 302, review_more_info: 303,
      finalize_closed: 401, finalize_signed: 402,
      filed_e_file: 501, filed_mail_file: 502, filed_rejected: 503, filed_accepted: 504
  }.freeze

  STATUSES_BY_STAGE = determine_statuses_by_stage.freeze
  STAGES = STATUSES_BY_STAGE.keys.freeze

  def self.message_template_for(status, locale = "en")
    message_templates[status.to_sym] ? I18n.t(message_templates[status.to_sym], locale: locale) : ""
  end
end