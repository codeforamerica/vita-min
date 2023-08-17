module SubmissionBuilder
  module Ty2022
    module States
      class ReturnHeader < SubmissionBuilder::Document
        include SubmissionBuilder::FormattingMethods
        include SubmissionBuilder::BusinessLogicMethods

        def document
          build_xml_doc("efile:ReturnHeaderState") do |xml|
            xml.Jurisdiction "#{@submission.bundle_class.state_abbreviation}ST"
            xml.ReturnTs datetime_type(@submission.created_at)
            xml.TaxPeriodBeginDt date_type(Date.new(@submission.data_source.tax_return_year, 1, 1))
            xml.TaxPeriodEndDt date_type(Date.new(@submission.data_source.tax_return_year, 12, 31))
            xml.TaxYr @submission.data_source.tax_return_year
            xml.OriginatorGrp do
              xml.EFIN EnvironmentCredentials.irs(:efin)
              xml.OriginatorTypeCd "OnlineFiler"
            end
            xml.SoftwareId EnvironmentCredentials.irs(:sin)
            xml.ReturnType "#{@submission.bundle_class.return_type}"
            xml.Filer do
              xml.Primary do
                xml.TaxpayerName do
                  xml.FirstName @submission.data_source.primary.first_name
                  xml.LastName @submission.data_source.primary.last_name
                end
                xml.TaxpayerSSN @submission.data_source.primary.ssn
              end
              xml.USAddress do |xml|
                xml.AddressLine1Txt @submission.data_source.street_address
                xml.CityNm @submission.data_source.city
                xml.StateAbbreviationCd @submission.bundle_class.state_abbreviation
                xml.ZIPCd @submission.data_source.zip_code
              end
            end
          end
        end
      end
    end
  end
end
