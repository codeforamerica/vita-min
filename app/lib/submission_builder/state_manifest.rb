module SubmissionBuilder
  class StateManifest < SubmissionBuilder::Document
    include SubmissionBuilder::FormattingMethods

    def schema_file
      File.join(Rails.root, "vendor", "irs", "unpacked", @schema_version, "Common", "efileAttachments.xsd")
    end

    def document
      data_source = @submission.data_source

      build_xml_doc("efile:StateSubmissionManifest") do |xml|
        xml.SubmissionId @submission.irs_submission_id
        xml.EFIN EnvironmentCredentials.irs(:efin)
        xml.TaxYr data_source.tax_return_year
        xml.GovernmentCd "IRS"
        # [TF,CT,TN,0-9]{2}[0-9]{7}
        # xml.StateSubmissionTyp "#{@submission.bundle_class.state_abbreviation}-1040"
        xml.StateSubmissionTyp "TFTN1234567"
        xml.SubmissionCategoryCd "IND"
        xml.PrimarySSN data_source.primary.ssn
        xml.PrimaryNameControlTxt name_control_type(data_source.primary.last_name)
      end
    end
  end
end
