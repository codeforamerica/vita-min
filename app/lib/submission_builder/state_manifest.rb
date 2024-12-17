module SubmissionBuilder
  class StateManifest < SubmissionBuilder::Document
    include SubmissionBuilder::FormattingMethods

    def schema_file
      SchemaFileLoader.load_file("irs", "unpacked", @schema_version, "Common", "efileAttachments.xsd")
    end

    def document
      data_source = @submission.data_source

      build_xml_doc("StateSubmissionManifest") do |xml|
        xml.SubmissionId @submission.irs_submission_id
        xml.EFIN EnvironmentCredentials.irs(:efin)
        xml.TaxYr data_source.tax_return_year
        xml.GovernmentCd "#{@submission.data_source.state_code.upcase}ST"
        xml.StateSubmissionTyp StateFile::StateInformationService.submission_type(@submission.data_source.state_code)
        xml.SubmissionCategoryCd "IND"
        xml.PrimarySSN data_source.primary.ssn
        xml.PrimaryNameControlTxt name_control_type(data_source.primary.last_name)
        if data_source.filing_status_mfj?
          xml.SpouseSSN data_source.spouse.ssn
          xml.SpouseNameControlTxt name_control_type(data_source.spouse.last_name)
        end
        xml.IRSSubmissionId data_source.federal_submission_id
      end
    end
  end
end
