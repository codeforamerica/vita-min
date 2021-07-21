module SubmissionBuilder
  module Documents
    class Scenario5Irs1040ScheduleA < SubmissionBuilder::Base
      include SubmissionBuilder::FormattingMethods

      @schema_file = File.join(Rails.root, "vendor", "irs", "unpacked", "2020v5.1", "IndividualIncomeTax", "Ind1040", "IRS1040ScheduleA", "IRS1040ScheduleA.xsd")
      @root_node = "IRS1040ScheduleA"

      def root_node_attrs
        software_id = EnvironmentCredentials.dig(:irs, :sin)
        super.merge(documentId: "IRS1040ScheduleA", documentName: "IRS1040ScheduleA", softwareVersionNum: "2020v5.1", softwareId: software_id)
      end

      def document
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.IRS1040ScheduleA(root_node_attrs) {
            xml.StateAndLocalSalesTaxInd "X"
            xml.TotalStateAndLocalTaxAmt 2010
            xml.StateAndLocalTaxLimitationAmt 2010
            xml.TotalTaxesPaidAmt 2010
            xml.TotalItemizedDeductionsAmt 2010
          }
        end.doc
      end
    end
  end
end