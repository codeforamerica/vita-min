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
        xml.GovernmentCd "#{@submission.bundle_class.state_abbreviation}ST"
        xml.StateSubmissionTyp @submission.bundle_class.return_type
        xml.SubmissionCategoryCd "IND"
        xml.PrimarySSN data_source.primary.ssn
        xml.PrimaryNameControlTxt name_control_type(data_source.primary.last_name)
        # xml.IRSSubmissionId data_source.federal_submission_id TODO: uncomment once DF returns are getting accepted
      end
    end
  end
end
