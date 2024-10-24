class SubmissionBuilder::Ty2024::States::Id::Documents::Id39r < SubmissionBuilder::Document
  def document
    @calculated_fields ||= @submission.data_source.tax_calculator.calculate
    build_xml_doc("Form39R") do |xml|
      xml.ChildCareCreditAmt @calculated_fields.fetch(:ID39R_LINE_B_6)
    end
  end
end
