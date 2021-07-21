module SubmissionBuilder
  module Documents
    class Scenario5Irs1040ScheduleEic < SubmissionBuilder::Base
      include SubmissionBuilder::FormattingMethods

      @schema_file = File.join(Rails.root, "vendor", "irs", "unpacked", "2020v5.1", "IndividualIncomeTax", "Common", "IRS1040ScheduleEIC", "IRS1040ScheduleEIC.xsd")
      @root_node = "IRS1040ScheduleEIC"

      def root_node_attrs
        software_id = EnvironmentCredentials.dig(:irs, :sin)
        super.merge(documentId: "IRS1040ScheduleEIC", documentName: "IRS1040ScheduleEIC", softwareVersionNum: "2020v5.1", softwareId: software_id)
      end

      def document
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.IRS1040ScheduleEIC(root_node_attrs) {
            xml.QualifyingChildInformation {
              xml.QualifyingChildNameControlTxt person_name_control_type("SAMMY WASHINGTON") #?
              xml.ChildFirstAndLastName {
                xml.PersonFirstNm "SAMMY"
                xml.PersonLastNm "WASHINGTON"
              }
              xml.QualifyingChildSSN "400001058"
              xml.ChildBirthYr "2010"
              xml.ChildRelationshipCd "SON"
              xml.MonthsChildLivedWithYouCnt "12"
            }
            xml.QualifyingChildInformation {
              xml.QualifyingChildNameControlTxt person_name_control_type("SUE WASHINGTON") #?
              xml.ChildFirstAndLastName {
                xml.PersonFirstNm "SUE"
                xml.PersonLastNm "WASHINGTON"
              }
              xml.QualifyingChildSSN "400001057"
              xml.ChildBirthYr "2009"
              xml.ChildRelationshipCd "DAUGHTER"
              xml.MonthsChildLivedWithYouCnt "12"
            }
          }
        end.doc
      end
    end
  end
end