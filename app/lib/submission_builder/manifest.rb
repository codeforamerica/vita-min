module SubmissionBuilder
  class Manifest
    include Buildable

    SCHEMA_FILE = File.join(Rails.root, "vendor", "irs", "unpacked", "2020v5.1", "Common", "efileAttachments.xsd")

    def initialize(submission)
      @submission = submission
      @intake = submission.intake
    end

    def build
      document = Nokogiri::XML::Builder.new do |xml|
        xml['efil'].IRSSubmissionManifest("xmlns:efil" => "http://www.irs.gov/efile", "xmlns" => "http://www.irs.gov/efile") {
          xml.SubmissionId @submission.irs_submission_id
          xml.EFIN EnvironmentCredentials.dig(:irs, :efin)
          xml.GovernmentCd "IRS"
          xml.FederalSubmissionTypeCd "1040"
          xml.TIN @intake.primary_ssn
        }
      end

      xsd = Nokogiri::XML::Schema(File.open(SCHEMA_FILE))
      xml = Nokogiri::XML(document.to_xml)
      SubmissionBuilder::Response.new(errors: xsd.validate(xml), document: document)
    end
  end
end