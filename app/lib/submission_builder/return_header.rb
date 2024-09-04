module SubmissionBuilder
  class ReturnHeader < SubmissionBuilder::Document
    include SubmissionBuilder::FormattingMethods
    include SubmissionBuilder::BusinessLogicMethods

    def document
      build_xml_doc("ReturnHeaderState") do |xml|
        xml.Jurisdiction "#{@submission.data_source.state_code.upcase}ST"
        xml.ReturnTs datetime_type(@submission.created_at) if @submission.created_at.present?
        xml.TaxPeriodBeginDt date_type(Date.new(@submission.data_source.tax_return_year, 1, 1))
        xml.TaxPeriodEndDt date_type(Date.new(@submission.data_source.tax_return_year, 12, 31))
        xml.TaxYr @submission.data_source.tax_return_year
        xml.OriginatorGrp do
          xml.EFIN EnvironmentCredentials.irs(:efin)
          xml.OriginatorTypeCd "OnlineFiler"
        end
        xml.SoftwareId EnvironmentCredentials.irs(:sin)
        xml.ReturnType StateFile::StateInformationService.return_type(@submission.data_source.state_code)
        xml.Filer do
          xml.Primary do
            xml.TaxpayerName do
              xml.FirstName sanitize_for_xml(@submission.data_source.primary.first_name, 16) if @submission.data_source.primary.first_name.present?
              xml.MiddleInitial sanitize_for_xml(@submission.data_source.primary.middle_initial, 1) if @submission.data_source.primary.middle_initial.present?
              xml.LastName sanitize_for_xml(@submission.data_source.primary.last_name, 32) if @submission.data_source.primary.last_name.present?
              xml.NameSuffix @submission.data_source.primary.suffix if @submission.data_source.primary.suffix.present?
            end
            xml.TaxpayerSSN @submission.data_source.primary.ssn if @submission.data_source.primary.ssn.present?
            xml.DateOfBirth date_type(@submission.data_source.primary.birth_date) if @submission.data_source.primary.birth_date.present?
          end
          if @submission.data_source&.spouse.ssn.present? && @submission.data_source&.spouse.first_name.present?
            xml.Secondary do
              xml.TaxpayerName do
                xml.FirstName sanitize_for_xml(@submission.data_source.spouse.first_name, 16) if @submission.data_source.spouse.first_name.present?
                xml.MiddleInitial sanitize_for_xml(@submission.data_source.spouse.middle_initial, 1) if @submission.data_source.spouse.middle_initial.present?
                xml.LastName sanitize_for_xml(@submission.data_source.spouse.last_name, 32) if @submission.data_source.spouse.last_name.present?
                xml.NameSuffix @submission.data_source.spouse.suffix if @submission.data_source.spouse.suffix.present?
              end
              xml.TaxpayerSSN @submission.data_source.spouse.ssn if @submission.data_source.spouse.ssn.present?
              xml.DateOfBirth date_type(@submission.data_source.spouse.birth_date) if @submission.data_source.spouse.birth_date.present?
              xml.DateOfDeath @submission.data_source.direct_file_data.spouse_date_of_death if @submission.data_source.direct_file_data.spouse_date_of_death.present?
            end
          end
          xml.USAddress do |xml|
            xml.AddressLine1Txt sanitize_for_xml(@submission.data_source.direct_file_data.mailing_street, 35) if @submission.data_source.direct_file_data.mailing_street.present?
            xml.AddressLine2Txt sanitize_for_xml(@submission.data_source.direct_file_data.mailing_apartment, 35) if @submission.data_source.direct_file_data.mailing_apartment.present?
            xml.CityNm sanitize_for_xml(@submission.data_source.direct_file_data.mailing_city, 22) if @submission.data_source.direct_file_data.mailing_city.present?
            xml.StateAbbreviationCd @submission.data_source.state_code.upcase
            xml.ZIPCd @submission.data_source.direct_file_data.mailing_zip if @submission.data_source.direct_file_data.mailing_zip.present?
          end
        end
      end
    end
  end
end
