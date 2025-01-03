module PdfFiller
  class Md502RPdf
    include PdfHelper

    def source_pdf_name
      "md502R-TY2024"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:md)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      {
      }
    end
  end
end
