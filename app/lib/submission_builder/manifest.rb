module SubmissionBuilder
  class Manifest < SubmissionBuilder::Base
    include SubmissionBuilder::FormattingMethods

    @schema_file = File.join(Rails.root, "vendor", "irs", "unpacked", "2020v5.1", "Common", "efileAttachments.xsd")
    @root_node = "IRSSubmissionManifest"

    def document
      intake = @submission.intake
      tax_return = @submission.tax_return

      Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml['efile'].IRSSubmissionManifest(root_node_attrs) {
          xml.SubmissionId @submission.irs_submission_id
          xml.EFIN EnvironmentCredentials.dig(:irs, :efin)
          xml.TaxYr tax_return.year
          xml.GovernmentCd "IRS"
          xml.FederalSubmissionTypeCd "1040"
          xml.TaxPeriodBeginDt date_type(Date.new(tax_return.year, 1, 1))
          xml.TaxPeriodEndDt date_type(Date.new(tax_return.year, 12, 31))
          xml.TIN intake.primary_ssn
        }
      end.doc
    end
  end
end