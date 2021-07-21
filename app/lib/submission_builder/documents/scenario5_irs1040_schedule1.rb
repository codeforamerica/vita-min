module SubmissionBuilder
  module Documents
    class Scenario5Irs1040Schedule1 < SubmissionBuilder::Base
      include SubmissionBuilder::FormattingMethods

      @schema_file = File.join(Rails.root, "vendor", "irs", "unpacked", "2020v5.1", "IndividualIncomeTax", "Ind1040", "IRS1040Schedule1", "IRS1040Schedule1.xsd")
      @root_node = "IRS1040Schedule1"

      def root_node_attrs
        software_id = EnvironmentCredentials.dig(:irs, :sin)
        super.merge(documentId: "IRS1040Schedule1", documentName: "IRS1040Schedule1", softwareVersionNum: "2020v5.1", softwareId: software_id)
      end

      def document
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.IRS1040Schedule1(root_node_attrs) {
            xml.IRADeductionAmt 1300
            xml.OtherAdjustmentsTotalAmt 1300
          }
        end.doc
      end
    end
  end
end