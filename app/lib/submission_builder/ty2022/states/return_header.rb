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
            xml.TaxYr @submission.tax_return.year
            xml.OriginatorGrp do
              xml.EFIN EnvironmentCredentials.irs(:efin)
              xml.OriginatorTypeCd "OnlineFiler"
            end
            xml.SoftwareId EnvironmentCredentials.irs(:sin)
            xml.ReturnType "#{@submission.bundle_class.return_type}"
            xml.Filer do
              xml.Primary do
                xml.TaxpayerName do
                  xml.FirstName @submission.intake.primary.first_name
                  xml.LastName @submission.intake.primary.last_name
                end
                xml.TaxpayerSSN @submission.intake.primary.ssn
              end
              xml.USAddress do |xml|
                xml.AddressLine1Txt @submission.intake.street_address
                xml.CityNm @submission.intake.city
                xml.StateAbbreviationCd @submission.bundle_class.state_abbreviation
                xml.ZIPCd @submission.intake.zip_code
              end
            end
          end
        end
      end
    end
  end
end
