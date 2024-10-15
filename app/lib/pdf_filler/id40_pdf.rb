module PdfFiller
  class Id40Pdf
    include PdfHelper

    def source_pdf_name
      "idform40-TY-2023"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:id)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      {
        "DateSign 2" => @submission.data_source.primary_esigned_at.strftime("%m-%d-%Y"),
        "TaxpayerPhoneNo" => @submission.data_source.direct_file_data.phone_number
      }
    end
  end
end
