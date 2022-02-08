class TaxReturnStatus
  class << self
    def message_templates
      {
        intake_info_requested: "hub.status_macros.needs_more_information",
        intake_greeter_info_requested: "hub.status_macros.intake_greeter_info_requested",
        intake_reviewing: "hub.status_macros.intake_reviewing",
        intake_ready_for_call: "hub.status_macros.intake_ready_for_call",
        prep_info_requested: "hub.status_macros.needs_more_information",
        prep_preparing: "hub.status_macros.prep_preparing",
        review_info_requested: "hub.status_macros.needs_more_information",
        review_reviewing: "hub.status_macros.review_reviewing",
        review_ready_for_call: "hub.status_macros.review_ready_for_call",
        review_signature_requested: "hub.status_macros.review_signature_requested",
        file_accepted: "hub.status_macros.file_accepted",
        file_efiled: "hub.status_macros.file_efiled",
        file_mailed: "hub.status_macros.file_mailed",
      }
    end
  end

  # If we ever need to add statuses between these numbers, we can multiply these by 100, do a data migration, and
  # then insert a value in between.
  # The first word of each status name is treated as a "stage" when grouping these in the interface.
  STATUSES = {
    intake_before_consent: 100, intake_in_progress: 101, intake_ready: 102, intake_reviewing: 103, intake_ready_for_call: 104, intake_info_requested: 105, intake_greeter_info_requested: 106, intake_needs_doc_help: 130,

    prep_ready_for_prep: 201, prep_preparing: 202, prep_info_requested: 203,

    review_ready_for_qr: 301, review_reviewing: 302, review_ready_for_call: 303, review_signature_requested: 304, review_info_requested: 305,

    file_needs_review: 400, file_ready_to_file: 401, file_efiled: 402, file_mailed: 403, file_rejected: 404, file_accepted: 405, file_not_filing: 406, file_hold: 450, file_fraud_hold: 460
  }.freeze

  def self.message_template_for(status, locale = "en")
    message_templates[status.to_sym] ? I18n.t(message_templates[status.to_sym], locale: locale) : ""
  end
end
