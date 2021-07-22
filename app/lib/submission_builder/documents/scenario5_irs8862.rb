module SubmissionBuilder
  module Documents
    class Scenario5Irs8862 < SubmissionBuilder::Base
      include SubmissionBuilder::FormattingMethods

      @schema_file = File.join(Rails.root, "vendor", "irs", "unpacked", "2020v5.1", "IndividualIncomeTax", "Common", "IRS8862", "IRS8862.xsd")
      @root_node = "IRS8862"

      def root_node_attrs
        software_id = EnvironmentCredentials.dig(:irs, :sin)
        super.merge(documentId: "IRS8862", documentName: "IRS8862", softwareVersionNum: "2020v5.1", softwareId: software_id)
      end

      def document
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.IRS8862(root_node_attrs) {
            xml.TaxYr "2020"
            xml.EICClaimedInd "X"
            xml.CTCACTCODCClaimedInd "X"
            xml.AOTCClaimedInd "X"
            xml.EICEligClmIncmIncorrectRptInd "false"
            xml.EICEligClmQlfyChldOfOtherInd "false"
            xml.QualifyingChildInd "true"
            xml.FilerWithQualifyingChildGrp {
              xml.ChildFirstAndLastName {
                xml.PersonFirstNm "SAMMY"
                xml.PersonLastNm "WASHINGTON"
              }
              xml.LiveInUSDayCnt "365"
            }
            xml.FilerWithQualifyingChildGrp {
              xml.ChildFirstAndLastName {
                xml.PersonFirstNm "SUE"
                xml.PersonLastNm "WASHINGTON"
              }
              xml.LiveInUSDayCnt "365"
            }
            xml.CTCACTCChildInformationGrp {
              xml.ChildFirstAndLastName {
                xml.PersonFirstNm "SUE"
                xml.PersonLastNm "WASHINGTON"
              }
              xml.LiveWithChildOverHalfYearInd "true"
              xml.QualifyingChildInd "true"
              xml.DependentInd "true"
              xml.USCitizenOrNationalInd "true"
            }
            xml.CTCACTCChildInformationGrp {
              xml.ChildFirstAndLastName {
                xml.PersonFirstNm "SAMMY"
                xml.PersonLastNm "WASHINGTON"
              }
              xml.LiveWithChildOverHalfYearInd "true"
              xml.QualifyingChildInd "true"
              xml.DependentInd "true"
              xml.USCitizenOrNationalInd "true"
            }
            xml.AOTCStudentInformationGrp {
              xml.StudentName {
                xml.PersonFirstNm "SARAH"
                xml.PersonLastNm "WASHINGTON"
              }
              xml.EligibleStudentInd "true"
              xml.PriorYearCreditClaimedInd "false"
            }
          }
        end.doc
      end
    end
  end
end