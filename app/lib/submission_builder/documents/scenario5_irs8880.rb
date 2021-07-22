module SubmissionBuilder
  module Documents
    class Scenario5Irs8880 < SubmissionBuilder::Base
      include SubmissionBuilder::FormattingMethods

      @schema_file = File.join(Rails.root, "vendor", "irs", "unpacked", "2020v5.1", "IndividualIncomeTax", "Common", "IRS8880", "IRS8880.xsd")
      @root_node = "IRS8880"

      def root_node_attrs
        software_id = EnvironmentCredentials.dig(:irs, :sin)
        super.merge(documentId: "IRS8880", documentName: "IRS8880", softwareVersionNum: "2020v5.1", softwareId: software_id)
      end

      def document
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.IRS8880(root_node_attrs) {
            xml.PrimaryRothIRAForCurrentYrAmt 1300
            xml.AddPrimRothIRAToCYContriAmt 1300
            xml.CalculatePrimDistribFromTotAmt 1300
            xml.PrimSmallerOfCalculationAmt 1300
            xml.TotalCalculatedAmt 1300
            xml.TaxReturnAGIAmt 28869
            xml.QlfyRetirementSavDecimalAmt "0.1"
            xml.CalculatedAmtByDecimalAmt 130
          }
        end.doc
      end
    end
  end
end