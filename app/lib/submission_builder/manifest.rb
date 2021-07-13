module SubmissionBuilder
  class Manifest < SubmissionBuilder::Base
    @schema_file = File.join(Rails.root, "vendor", "irs", "unpacked", "2020v5.1", "Common", "efileAttachments.xsd")
    @root_node = "IRSSubmissionManifest"

    def document
      intake = @submission.intake

      Nokogiri::XML::Builder.new do |xml|
        xml['efil'].IRSSubmissionManifest(root_node_attrs) {
          xml.SubmissionId @submission.irs_submission_id
          xml.EFIN EnvironmentCredentials.dig(:irs, :efin)
          xml.GovernmentCd "IRS"
          xml.FederalSubmissionTypeCd "1040"
          xml.TIN intake.primary_ssn
        }
      end.doc
    end
  end
end