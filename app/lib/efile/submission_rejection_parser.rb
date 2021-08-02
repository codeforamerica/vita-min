module Efile
  class SubmissionRejectionParser
    attr_accessor :xml
    def initialize(raw_response)
      @raw_response = raw_response
    end

    def to_xml
      Nokogiri::XML(@raw_response)
    end

    def errors
      errors = []
      to_xml.search("ValidationErrorGrp").each do |error_group|
        errors << Efile::Error.new(
          code: error_group.at("RuleNum")&.text,
          message: error_group.at("ErrorMessageTxt")&.text,
          category: error_group.at("ErrorCategoryCd")&.text,
          severity: error_group.at("SeverityCd")&.text
        )
      end
      errors
    end
  end
end