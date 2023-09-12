module PdfFiller
  class Az140Pdf
    include PdfHelper

    def source_pdf_name
      "az140-TY2022"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      @xml_document = SubmissionBuilder::Ty2022::States::Az::IndividualReturn.new(submission).document
    end

    def hash_for_pdf
      answers = {
        "1a" => [@submission.data_source.primary.first_name, @submission.data_source.primary.middle_initial].map(&:presence).compact.join(' '),
        "1b" => @submission.data_source.primary.last_name,
      }
      answers
    end
  end
end
