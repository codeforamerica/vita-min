module SubmissionBuilder::Ty2022::States::Az::Documents
  class Az140 < SubmissionBuilder::Document
    include SubmissionBuilder::FormattingMethods

    def document
      build_xml_doc("Form140") do |xml|
        xml.LNPriorYrs claimed: @submission.data_source&.prior_last_names
        xml.FilingStatus claimed: @submission.data_source.filing_status
        xml.Exemptions claimed: 1 # TODO fix after we figure out dependent information
        xml.QualifyingParentsAncestors claimed: 1 # TODO fix after we figure out dependent information

      end
    end

    private

    def calculated_fields
      @calculated_fields ||= @submission.data_source.tax_calculator.calculate
    end
  end
end

