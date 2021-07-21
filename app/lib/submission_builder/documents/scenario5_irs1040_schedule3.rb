module SubmissionBuilder
  module Documents
    class Scenario5Irs1040Schedule3 < SubmissionBuilder::Base
      include SubmissionBuilder::FormattingMethods

      @schema_file = File.join(Rails.root, "vendor", "irs", "unpacked", "2020v5.1", "IndividualIncomeTax", "Ind1040", "IRS1040Schedule3", "IRS1040Schedule3.xsd")
      @root_node = "IRS1040Schedule3"

      def root_node_attrs
        software_id = EnvironmentCredentials.dig(:irs, :sin)
        super.merge(documentId: "IRS1040Schedule3", documentName: "IRS1040Schedule3", softwareVersionNum: "2020v5.1", softwareId: software_id)
      end

      def document
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.IRS1040Schedule3(root_node_attrs) {
            xml.CreditForChildAndDepdCareAmt 408
            xml.TotalNonrefundableCreditsAmt 408
          }
        end.doc
      end
    end
  end
end