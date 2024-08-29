module PdfFiller
  class NcD400Pdf
    include PdfHelper

    def source_pdf_name
      "ncD400-TY2024"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:nc)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      {}
    end

    private

    def calculated_fields
      @calculated_fields ||= @submission.data_source.tax_calculator.calculate
    end
  end
end
