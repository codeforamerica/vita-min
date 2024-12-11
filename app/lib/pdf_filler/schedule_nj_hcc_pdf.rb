module PdfFiller
  class ScheduleNjHccPdf
    include PdfHelper
    include StateFile::NjPdfHelper

    def source_pdf_name
      "schedule-njhcc"
    end

    def initialize(submission)
      @submission = submission

      builder = StateFile::StateInformationService.submission_builder_class(:nj)
      @parent_xml_doc = builder.new(submission).document
    end

    def hash_for_pdf
      {
        'Names as shown on Form NJ1040': get_name(@parent_xml_doc),
        'Social Security Number': get_taxpayer_ssn,
        Group1: "Choice1"
      }
    end

    private

    def intake
      @submission.data_source
    end

    def get_taxpayer_ssn
      @parent_xml_doc.at("ReturnHeaderState Filer Primary TaxpayerSSN")&.text
    end

  end
end
