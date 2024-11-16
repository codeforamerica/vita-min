module PdfFiller
  class Id39rPdf
    include PdfHelper

    def source_pdf_name
      "idform39r-TY2023"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:id)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      answers = {
        "AL7" => @xml_document.at('Form39R TotalAdditions')&.text,
        "BL3" => @xml_document.at('Form39R IncomeUSObligations')&.text,
        "BL6" => @xml_document.at('Form39R ChildCareCreditAmt')&.text,
        "BL7" => @xml_document.at('Form39R TxblSSAndRRBenefits')&.text,
        "BL8f" => @xml_document.at('Form39R RetirementBenefitsDeduction')&.text,
        "BL18" => @xml_document.at('Form39R HealthInsurancePaid')&.text,
        "BL24" => @xml_document.at('Form39R TotalSubtractions')&.text,
        "DL4" => @xml_document.at('Form39R TotalSupplementalCredits')&.text,
      }
      @submission.data_source.dependents.drop(4).first(3).each_with_index do |dependent, index|
        answers.merge!(
          "FR#{index + 1}FirstName" => dependent.first_name,
          "FR#{index + 1}LastName" => dependent.last_name,
          "FR#{index + 1}SSN" => dependent.ssn,
          "FR#{index + 1}Birthdate" => dependent.dob.strftime('%m/%d/%Y'),
          )
      end
      answers
    end
  end
end
