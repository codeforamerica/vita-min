module Efile
  class SubmissionErrorParser
    attr_accessor :xml
    def initialize(transition)
      @transition = transition
      @raw_response = transition.metadata["raw_response"]
    end

    def persist_errors
      metadata = @transition.metadata
      # these errors are mostly failures on our side of things, like issues with bundling and addresses
      if metadata["error_code"].present?
        persist_errors_from_error_metadata
      end

      if @transition.to_state == "failed" && metadata["raw_response"].present?
        persist_bundle_errors_from_raw_response_metadata
      end

      # there errors are responses from the IRS, like rejections or exceptions
      if @transition.to_state == "rejected" && metadata["raw_response"].present?
        persist_errors_from_raw_response_metadata
      end
    end

    private

    def persist_errors_from_error_metadata
      efile_submission = @transition.efile_submission
      metadata = @transition.metadata

      attrs = { code: metadata["error_code"] }
      attrs[:message] = metadata["error_message"] if metadata["error_message"].present?
      attrs[:source] = metadata["error_source"] if metadata["error_source"].present?
      efile_error = EfileError.find_or_create_by!(attrs)

      @transition.efile_submission_transition_errors.create(efile_submission_id: efile_submission.id, efile_error: efile_error)
    end

    def persist_errors_from_raw_response_metadata
      as_xml = Nokogiri::XML(@raw_response)

      raise UnexpectedFormatError, "raw_response on transition is not in expected format" unless as_xml.at("ValidationErrorGrp").present?

      as_xml.search("ValidationErrorGrp").each do |error_group|
        error = EfileError.find_or_create_by!(
          code: error_group.at("RuleNum")&.text,
          message: error_group.at("ErrorMessageTxt")&.text,
          category: error_group.at("ErrorCategoryCd")&.text,
          severity: error_group.at("SeverityCd")&.text,
          source: "irs"
        )
        identifier = error_group.at("FieldValueTxt")&.text
        dependent_id = nil

        if identifier.present?
          @transition.efile_submission.dependents.each do |dependent|
            dependent_id = dependent.id if dependent.ssn == identifier
          end
        end
        @transition.efile_submission_transition_errors.create(efile_submission_id: @transition.efile_submission.id, efile_error_id: error.id, dependent_id: dependent_id)
      end
    end

    def persist_bundle_errors_from_raw_response_metadata
      if @transition.metadata["raw_response"].to_s.match?(/(RoutingTransitNum|DepositorAccountNum)/)
        error = EfileError.find_by(
          code: "BANK-DETAILS"
        )
        @transition.efile_submission_transition_errors.create(efile_submission_id: @transition.efile_submission.id, efile_error_id: error.id)
      end
    end

    def self.persist_errors(*args)
      new(*args).persist_errors
    end
  end

  class UnexpectedFormatError < StandardError; end
end