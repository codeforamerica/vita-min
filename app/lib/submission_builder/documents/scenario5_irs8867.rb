module SubmissionBuilder
  module Documents
    class Scenario5Irs8867 < SubmissionBuilder::Base
      include SubmissionBuilder::FormattingMethods

      @schema_file = File.join(Rails.root, "vendor", "irs", "unpacked", "2020v5.1", "IndividualIncomeTax", "Common", "IRS8867", "IRS8867.xsd")
      @root_node = "IRS8867"

      def root_node_attrs
        software_id = EnvironmentCredentials.dig(:irs, :sin)
        super.merge(documentId: "IRS8867", documentName: "IRS8867", softwareVersionNum: "2020v5.1", softwareId: software_id)
      end

      def document
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.IRS8867(root_node_attrs) {
            xml.PreparerPersonNm "IRS"
            xml.PTIN "P12345678" # doesn't take "S12345678"
            xml.EICClaimedInd "X"
            xml.CTCACTCODCClaimedInd "X"
            xml.AOTCClaimedInd "X"
            xml.TxpyrProvidedOrObtainedInfoInd "true"
            xml.CompleteApplicableWorksheetCd "YES"
            xml.SatisfyKnowledgeRequirementInd "true"
            xml.IncorIncmplInconInfoInd "false"
            xml.SatisfyRecordRetentionRqrInd "true"
            xml.SubstantiateCrEligibilityInd "true"
            xml.PrevDisallowedOrReducedCrCd "YES"
            xml.CompleteRequiredRecertFormCd "YES"
            xml.QstnToCompleteCorrectSchCCd "N/A"
            xml.EICEligibleClaimQlfyChildInd "true"
            xml.ExplainLiveWithChldRqrClaimInd "true"
            xml.ExplainTiebreakerRulesCd "YES"
            xml.USCitizenOrNationalInd "true"
            xml.ExplainLiveWithChldRqrClaimCd "YES"
            xml.ExplainRuleClmCrDivPrnts8332Cd "YES"
            xml.SubstProvQlfyTuitionExpnssInd "false"
            xml.CrEligibilityCertificationInd "true"
          }
        end.doc
      end
    end
  end
end