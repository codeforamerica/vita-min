module PdfFiller
  class Az322Pdf
    include PdfHelper

    def source_pdf_name
      "az322-TY2023"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:az)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      answers = {
      }
    end
  end
end
