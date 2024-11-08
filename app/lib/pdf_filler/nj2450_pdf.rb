module PdfFiller
  class Nj2450Pdf
    include PdfHelper

    def source_pdf_name
      "nj2450-TY2023"
    end

    def initialize(submission)
      @submission = submission

      builder = StateFile::StateInformationService.submission_builder_class(:nj)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      {

      }
    end


  end
end
