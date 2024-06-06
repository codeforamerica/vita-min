module SubmissionBuilder
  class FederalManifest < SubmissionBuilder::Document
    include SubmissionBuilder::FormattingMethods

    def schema_file
      SchemaFileLoader.load_file("irs", "unpacked", @schema_version, "Common", "efileAttachments.xsd")
    end

    def document
      intake = @submission.intake
      tax_return = @submission.tax_return

      build_xml_doc("efile:IRSSubmissionManifest") do |xml|
        xml.SubmissionId @submission.irs_submission_id
        xml.EFIN EnvironmentCredentials.irs(:efin)
        xml.TaxYr tax_return.year
        xml.GovernmentCd "IRS"
        xml.FederalSubmissionTypeCd "1040"
        xml.TaxPeriodBeginDt date_type(Date.new(tax_return.year, 1, 1))
        xml.TaxPeriodEndDt date_type(Date.new(tax_return.year, 12, 31))
        xml.TIN intake.primary.ssn
      end
    end
  end
end
