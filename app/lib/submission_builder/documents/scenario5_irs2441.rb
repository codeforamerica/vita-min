module SubmissionBuilder
  module Documents
    class Scenario5Irs2441 < SubmissionBuilder::Base
      include SubmissionBuilder::FormattingMethods

      @schema_file = File.join(Rails.root, "vendor", "irs", "unpacked", "2020v5.1", "IndividualIncomeTax", "Common", "IRS2441", "IRS2441.xsd")
      @root_node = "IRS2441"

      def root_node_attrs
        software_id = EnvironmentCredentials.dig(:irs, :sin)
        super.merge(documentId: "IRS2441", documentName: "IRS2441", softwareVersionNum: "2020v5.1", softwareId: software_id)
      end

      def document
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.IRS2441(root_node_attrs) {
            xml.CareProviderGrp {
              xml.CareProviderBusinessName {
                xml.BusinessNameLine1Txt "DEVELOPING MINDS"
              }
              xml.CareProviderBusNameControlTxt business_name_control_type("DEVELOPING MINDS")
              xml.USAddress {
                xml.AddressLine1Txt "777 BLUE ST"
                xml.CityNm "TIPTOP"
                xml.StateAbbreviationCd "VA"
                xml.ZIPCd "24630"
              }
              xml.EIN "010000041"
              xml.PaidAmt 1100
            }
            xml.CareProviderGrp {
              xml.CareProviderBusinessName {
                xml.BusinessNameLine1Txt "LITTLE PEOPLE"
              }
              xml.CareProviderBusNameControlTxt business_name_control_type("LITTLE PEOPLE")
              xml.USAddress {
                xml.AddressLine1Txt "888 RED ST"
                xml.CityNm "TIPTOP"
                xml.StateAbbreviationCd "VA"
                xml.ZIPCd "24630"
              }
              xml.EIN "010000042"
              xml.PaidAmt 1200
            }
            xml.QualifyingPersonGrp {
              xml.QualifyingPersonName{
                xml.PersonFirstNm "SUE"
                xml.PersonLastNm "WASHINGTON"
              }
              xml.QualifyingPersonNameControlTxt "SUEW"
              xml.QualifyingPersonSSN "400001057"
            }
            xml.QualifyingPersonGrp {
              xml.QualifyingPersonName{
                xml.PersonFirstNm "SAMMY"
                xml.PersonLastNm "WASHINGTON"
              }
              xml.QualifyingPersonNameControlTxt "SAMM"
              xml.QualifyingPersonSSN "400001058"
            }
          }
        end.doc
      end
    end
  end
end