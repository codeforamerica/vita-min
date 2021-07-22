module SubmissionBuilder
  module Documents
    class Scenario5Irs1040Schedule8812 < SubmissionBuilder::Base
      include SubmissionBuilder::FormattingMethods

      @schema_file = File.join(Rails.root, "vendor", "irs", "unpacked", "2020v5.1", "IndividualIncomeTax", "Common", "IRS1040Schedule8812", "IRS1040Schedule8812.xsd")
      @root_node = "IRS1040Schedule8812"

      def root_node_attrs
        software_id = EnvironmentCredentials.dig(:irs, :sin)
        super.merge(documentId: "IRS1040Schedule8812", documentName: "IRS1040Schedule8812", softwareVersionNum: "2020v5.1", softwareId: software_id)
      end

      def document
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.IRS1040Schedule8812(root_node_attrs) {
            xml.TaxLessCreditsAmt "4000"
            xml.ACTCBeforeLimitAmt "4000"
            xml.QlfyChildUnderAgeSSNCnt "2"
            xml.QlfyChildUnderAgeSSNLimtAmt "2800"
            xml.ACTCAfterLimitAmt "2800"
            xml.TotalEarnedIncomeAmt "30169"
            xml.EarnedIncmMoreThanSpecifiedInd "true"
            xml.NetTotalEarnedIncomeAmt "27669"
            xml.NetEarnedIncomeCalculatedAmt "4150"
            xml.ThreeOrMoreQlfyChildrenInd "true"
            xml.AdditionalChildTaxCreditAmt "2800"
          }
        end.doc
      end
    end
  end
end