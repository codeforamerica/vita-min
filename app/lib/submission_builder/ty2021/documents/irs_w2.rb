module SubmissionBuilder
  module Ty2021
    module Documents
      class IrsW2 < SubmissionBuilder::Document
        include SubmissionBuilder::FormattingMethods

        def schema_file
          File.join(Rails.root, "vendor", "irs", "unpacked", @schema_version, "IndividualIncomeTax", "Common", "IRSW2", "IRSW2.xsd")
        end

        def document
          intake = submission.intake

          build_xml_doc("IRSW2", documentId: "IRSW2", documentName: "IRSW2") do |xml|
            xml.EmployeeSSN intake.primary_ssn
            xml.EmployerEIN '000001234'
            xml.EmployerNameControlTxt 'CFA'
            xml.EmployerName do |xml|
              xml.BusinessNameLine1Txt 'Code for America'
            end
            xml.EmployerUSAddress do |xml|
              xml.AddressLine1Txt '123 Main St'
              xml.CityNm 'San Francisco'
              xml.StateAbbreviationCd 'CA'
              xml.ZIPCd '94121'
            end
            xml.EmployeeNm intake.primary_full_name
            xml.EmployeeUSAddress do |xml|
              xml.AddressLine1Txt '124 Main St'
              xml.CityNm 'San Francisco'
              xml.StateAbbreviationCd 'CA'
              xml.ZIPCd '94121'
            end
            xml.WagesAmt 1000
            xml.WithholdingAmt 100
            xml.StandardOrNonStandardCd 'S'
          end
        end
      end
    end
  end
end
