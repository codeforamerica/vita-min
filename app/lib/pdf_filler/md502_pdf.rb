module PdfFiller
  class Md502Pdf
    include PdfHelper

    def source_pdf_name
      "md502-TY2023"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:md)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      {
        "Enter day and month of Fiscal Year beginning": formatted_date(@xml_document.at('ReturnHeaderState TaxPeriodBeginDt')&.text, "%m-%d"),
        "Enter day and month of Fiscal Year Ending": formatted_date(@xml_document.at('ReturnHeaderState TaxPeriodEndDt')&.text, "%m-%d"),
        "Check Box - 1": filing_status(:filing_status_single?) ? 'Yes' : 'Off',
        "Check Box - 2": filing_status(:filing_status_mfj?) ? 'Yes' : 'Off',
        "Check Box - 3": filing_status(:filing_status_mfs?) ? 'Yes' : 'Off',
        "Check Box - 4": filing_status(:filing_status_hoh?) ? 'Yes' : 'Off',
        "Check Box - 5": filing_status(:filing_status_qw?) ? 'Yes' : 'Off',
        "6. Check here": claimed_as_dependent? ? 'Yes' : 'Off',
      }
    end

    def claimed_as_dependent?
      @submission.data_source.direct_file_data.claimed_as_dependent?
    end

    def filing_status(method)
      claimed_as_dependent? ? false : @submission.data_source.send(method)
    end

    def formatted_date(date_str, format)
      return if date_str.nil?

      Date.parse(date_str)&.strftime(format)
    end
  end
end
