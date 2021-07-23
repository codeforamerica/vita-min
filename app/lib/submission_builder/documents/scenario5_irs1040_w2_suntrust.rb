module SubmissionBuilder
  module Documents
    class Scenario5Irs1040W2Suntrust < SubmissionBuilder::Base
      include SubmissionBuilder::FormattingMethods

      @schema_file = File.join(Rails.root, "vendor", "irs", "unpacked", "2020v5.1", "IndividualIncomeTax", "Common", "IRSW2", "IRSW2.xsd")
      @root_node = "IRSW2"

      def root_node_attrs
        software_id = EnvironmentCredentials.dig(:irs, :sin)
        super.merge(documentId: "IRSW2Suntrust", documentName: "IRSW2", softwareVersionNum: "2020v5.1", softwareId: software_id)
      end

      def document
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.IRSW2(root_node_attrs) {
            xml.EmployeeSSN "400001039"
            xml.EmployerEIN "000000029"
            xml.EmployerNameControlTxt "SUNT"
            xml.EmployerName {
              xml.BusinessNameLine1Txt "Suntrust Bank"
            }
            xml.EmployerUSAddress {
              xml.AddressLine1Txt "330 PALM BEACH ST"
              xml.CityNm "VIRGINIA BEACH"
              xml.StateAbbreviationCd "VA"
              xml.ZIPCd "23450"
            }
            xml.EmployeeNm "Sarah Washington"
            xml.EmployeeUSAddress {
              xml.AddressLine1Txt "1111 MULBERRY ST"
              xml.CityNm "ALEXANDRIA"
              xml.StateAbbreviationCd "VA"
              xml.ZIPCd "22309"
            }
            xml.WagesAmt 30169
            xml.WithholdingAmt 2110
            xml.SocialSecurityWagesAmt 30169
            xml.SocialSecurityTaxAmt 1879
            xml.MedicareWagesAndTipsAmt 30169
            xml.MedicareTaxWithheldAmt 437
            xml.W2StateLocalTaxGrp {
              xml.W2StateTaxGrp {
                xml.StateAbbreviationCd "VA"
                xml.EmployerStateIdNum "000000003"
                xml.StateWagesAmt 30169
                xml.StateIncomeTaxAmt 2010
              }
            }
            xml.StandardOrNonStandardCd "S"
            xml.W2SecurityInformation {
              xml.W2DownloadCd 0
            }
          }
        end.doc
      end
    end
  end
end