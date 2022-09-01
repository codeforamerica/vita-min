module SubmissionBuilder
  module Ty2021
    module Documents
      class IrsW2 < SubmissionBuilder::Document
        include SubmissionBuilder::FormattingMethods

        def schema_file
          File.join(Rails.root, "vendor", "irs", "unpacked", @schema_version, "IndividualIncomeTax", "Common", "IRSW2", "IRSW2.xsd")
        end

        def document
          w2 = @kwargs[:w2]

          build_xml_doc("IRSW2", documentId: "IRSW2-#{w2.id}", documentName: "IRSW2") do |xml|
            xml.EmployeeSSN w2.employee_ssn
            xml.EmployerEIN w2.employer_ein
            xml.EmployerNameControlTxt name_control_type(w2.employer_name)
            xml.EmployerName do |xml|
              xml.BusinessNameLine1Txt w2.employer_name
            end
            xml.EmployerUSAddress do |xml|
              xml.AddressLine1Txt w2.employer_street_address
              xml.CityNm w2.employer_city
              xml.StateAbbreviationCd w2.employer_state
              xml.ZIPCd w2.employer_zip_code
            end
            xml.EmployeeNm person_name_type("#{w2.legal_first_name} #{w2.legal_last_name}", length: 35)
            xml.EmployeeUSAddress do |xml|
              xml.AddressLine1Txt w2.employee_street_address
              xml.CityNm w2.employee_city
              xml.StateAbbreviationCd w2.employee_state
              xml.ZIPCd w2.employee_zip_code
            end
            xml.WagesAmt w2.wages_amount.to_int
            xml.WithholdingAmt w2.federal_income_tax_withheld.to_int
            xml.StandardOrNonStandardCd w2.standard_or_non_standard_code
          end
        end
      end
    end
  end
end
