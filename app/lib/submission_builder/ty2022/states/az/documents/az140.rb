module SubmissionBuilder::Ty2022::States::Az::Documents
  class Az140 < SubmissionBuilder::Document
    include SubmissionBuilder::FormattingMethods

    def document
      build_xml_doc("IT215") do |xml|

      end
    end

    private

    def calculated_fields
      @calculated_fields ||= @submission.data_source.tax_calculator.calculate
    end
  end
end

