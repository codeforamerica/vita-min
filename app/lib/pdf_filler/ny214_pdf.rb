module PdfFiller
  class Ny214Pdf
    include PdfHelper

    def source_pdf_name
      "it214-TY2022"
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
        'Your first name' => @submission.data_source.primary.first_name,
        'Your MI' => @submission.data_source.primary.middle_initial,
        'Your last name' => @submission.data_source.primary.last_name,
        'Your DOB' =>  @submission.data_source.primary.birth_date.strftime("%m%d%Y"),
        'Your SSN' => @submission.data_source.primary.ssn,
        'Spouse\'s first name' => @submission.data_source.spouse&.first_name,
        'Spouse\'s MI' => @submission.data_source.spouse&.middle_initial,
        'Spouse\'s last name' => @submission.data_source.spouse&.last_name,
        'Spouse DOB' =>  @submission.data_source.spouse&.birth_date&.strftime("%m%d%Y"),
        'Spouse\'s SSN' => @submission.data_source.spouse&.ssn,
        'Mailing address' => @xml_document.at('tiPrime MAIL_LN_2_ADR')&.text,
        'NY State county of residence' =>  @submission.data_source.residence_county,
        'City, village or post office 1' => @xml_document.at('tiPrime MAIL_CITY_ADR')&.text,
        'State 1' => @submission.data_source.mailing_state,
        'ZIPcode 1' => @xml_document.at('tiPrime MAIL_ZIP_5_ADR')&.text,
        'Country' => @submission.data_source.mailing_country,
        'permanent home address' => @submission.data_source.ny_mailing_street,
        'city, village or post office 2' => @submission.data_source.permanent_street
      }
    end

    private

    FIELD_OPTIONS = {
    }
  end
end
