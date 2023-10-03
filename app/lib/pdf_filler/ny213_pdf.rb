module PdfFiller
  class Ny213Pdf
    include PdfHelper

    def source_pdf_name
      "it213-TY2022"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      @xml_document = SubmissionBuilder::Ty2022::States::Ny::IndividualReturn.new(submission).document
      @calculator = submission.data_source.tax_calculator
      @calculator.calculate
    end

    def hash_for_pdf
      answers = {
        'Your last name' => @submission.data_source.primary.full_name,
        'Your SSN' => @submission.data_source.primary.ssn,
        'Line 6 Dollars' => @calculator.lines[:IT213_AMT_6].value
      }
    end

  end
end
