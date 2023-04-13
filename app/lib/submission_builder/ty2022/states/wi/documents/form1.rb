module SubmissionBuilder
  module Ty2022
    module States
      module Wi
        module Documents
          class Form1 < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              build_xml_doc("Form1") do |xml|
                xml.Header do
                  xml.FilingStatus do
                    xml.Single 'X'
                  end
                  xml.TypeTaxDistrict 'City'
                  xml.TaxDistrict 'Madison'
                  xml.County '13 Dane'
                  xml.SchoolDistrict 'Madison - 3269'
                end
                xml.Body do
                  xml.FederalTaxableIncome 5000
                  xml.WisconsinTaxableIncome 4000
                  xml.StateIncome 4000
                  xml.StateTaxableIncome 3000
                  xml.StateIncomeTax 500
                  xml.NetStateTax 500
                end
                xml.SignatureArea do
                  xml.Signature do
                    xml.PrimarySignature do
                      xml.SignersName "Sammy Signature"
                      xml.Date "2023-05-01"
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end