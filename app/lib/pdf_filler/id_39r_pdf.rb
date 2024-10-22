module PdfFiller
  class Id39rPdf
    include PdfHelper
    def source_pdf_name = "idform39r-TY2023"

    def initialize(submission)
      @submission = submission

      builder = StateFile::StateInformationService.submission_builder_class(:id)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      {
        "BL6" => @xml_document.at('Form39R ChildCareCreditAmt')&.text
      }
    end
  end
end
