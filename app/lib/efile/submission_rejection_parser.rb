module Efile
  class SubmissionRejectionParser
    attr_accessor :xml
    def initialize(transition)
      @transition = transition
      @raw_response = transition.metadata["raw_response"]
    end

    def to_xml
      Nokogiri::XML(@raw_response)
    end

    def persist_errors
      raise UnexpectedFormatError, "raw_response on transition is not in expected format" unless to_xml.at("ValidationErrorGrp").present?

      to_xml.search("ValidationErrorGrp").each do |error_group|
        error = EfileError.find_or_create_by!(
          code: error_group.at("RuleNum")&.text,
          message: error_group.at("ErrorMessageTxt")&.text,
          category: error_group.at("ErrorCategoryCd")&.text,
          severity: error_group.at("SeverityCd")&.text,
          source: "irs"
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