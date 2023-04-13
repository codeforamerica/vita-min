module SubmissionBuilder
  class StateManifest < SubmissionBuilder::Document
    include SubmissionBuilder::FormattingMethods

    def schema_file
      File.join(Rails.root, "vendor", "irs", "unpacked", @schema_version, "Common", "efileAttachments.xsd")
    end

    def document
      intake = @submission.intake
      tax_return = @submission.tax_return

      build_xml_doc("efile:StateSubmissionManifest") do |xml|
        xml.SubmissionId @submission.irs_submission_id
        xml.EFIN EnvironmentCredentials.irs(:efin)
        xml.TaxYr tax_return.year
        xml.GovernmentCd "IRS"
        xml.StateSubmissionTyp "IL-1040"
        xml.SubmissionCategoryCd "IND"
        xml.PrimarySSN intake.primary.ssn
        xml.PrimaryNameControlTxt name_control_type(intake.primary.last_name)
      end
    end
  end
end
