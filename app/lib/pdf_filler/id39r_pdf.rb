module PdfFiller
  class Id39rPdf
    include PdfHelper

    def source_pdf_name
      "idform39r-TY2024"
    end

    def initialize(submission)
      @submission = submission
      @intake = submission.data_source

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:id)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      answers = {
        "Names" => formatted_display_name,
        "SSN" => @xml_document.at('Primary TaxpayerSSN')&.text,
        "AL7" => @xml_document.at('Form39R TotalAdditions')&.text,
        "BL3" => @xml_document.at('Form39R IncomeUSObligations')&.text,
        "BL6" => @xml_document.at('Form39R ChildCareCreditAmt')&.text,
        "BL7" => @xml_document.at('Form39R TxblSSAndRRBenefits')&.text,
        "BL8a" => @xml_document.at('Form39R PensionFilingStatusAmount')&.text,
        "BL8c" => @xml_document.at('Form39R SocialSecurityBenefits')&.text,
        "BL8d" => calculated_fields.fetch(:ID39R_B_LINE_8d),
        "BL8e" => @xml_document.at('Form39R PensionExclusions')&.text,
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

    private
    def calculated_fields
      @calculated_fields ||= @submission.data_source.tax_calculator.calculate
    end

    def formatted_display_name
      primary_capitalized_first_name = @intake.primary.first_name.capitalize
      primary_capitalized_last_name = @intake.primary.last_name.capitalize
      if @intake.state_filing_status_mfj?
        spouse_capitalized_first_name = @intake.spouse.first_name.capitalize
        spouse_capitalized_last_name = @intake.spouse.last_name.capitalize
        if primary_capitalized_last_name == spouse_capitalized_last_name
          primary_capitalized_first_name + " & " + spouse_capitalized_first_name + " " + spouse_capitalized_last_name
        else
          "#{primary_capitalized_first_name} #{primary_capitalized_last_name} & #{spouse_capitalized_first_name} #{spouse_capitalized_last_name}"
        end
      else
        "#{primary_capitalized_first_name} #{primary_capitalized_last_name}"
      end
    end
  end
end
