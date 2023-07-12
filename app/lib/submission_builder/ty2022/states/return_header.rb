module SubmissionBuilder
  module Ty2022
    module States
      class ReturnHeader < SubmissionBuilder::Document
        include SubmissionBuilder::FormattingMethods
        include SubmissionBuilder::BusinessLogicMethods

        def document
          build_xml_doc("efile:ReturnHeaderState") do |xml|
            xml.Jurisdiction "WIST"
            xml.ReturnTs '2023-10-10T12:00:00-05:00'
            xml.TaxYr '2022'
            xml.OriginatorGrp do
              xml.EFIN "123456"
              xml.OriginatorTypeCd "OnlineFiler"
            end
            xml.SoftwareId "microcompu"
            xml.SoftwareVersionNum "22"
            xml.SignatureOption do
              xml.SignaturePIN do
                xml.Signature 'Practitioner'
              end
            end
            xml.ReturnType 'MI1040'
            xml.Filer do
              xml.Primary do
                xml.TaxpayerName do
                  xml.FirstName "Jeff"
                  xml.LastName "Jeep"
                end
                xml.TaxpayerSSN "555002222"
              end
              xml.USAddress do |xml|
                xml.AddressLine1Txt '123 cool st'
                xml.CityNm 'cool city'
                xml.StateAbbreviationCd 'IL'
                xml.ZIPCd 60007
              end
            end
          end
        end
      end
    end
  end
end
