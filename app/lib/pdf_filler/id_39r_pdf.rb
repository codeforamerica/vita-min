module PdfFiller
  class Id39rPdf
    include PdfHelper
    def source_pdf_name = "idform394-TY2023.pdf"

    def initialize(submission)
      @submission = submission
    end
  end
end
