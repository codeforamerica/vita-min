module PdfFiller
  class Md502bPdf
    include PdfHelper

    def source_pdf_name
      "md502B-TY2023"
    end

    def initialize(submission)
      @submission = submission
      @intake = submission.data_source

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:md)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      answers = {
        "Your first name": @xml_document.at("Primary TaxpayerName FirstName")&.text,
        "Initial": @xml_document.at("Primary TaxpayerName MiddleInitial")&.text,
        "yOUR Last name": @xml_document.at("Primary TaxpayerName LastName")&.text,
        "social security 1": @xml_document.at("Primary TaxpayerSSN")&.text,
        "Spouses first name": @xml_document.at("Secondary TaxpayerName FirstName")&.text,
        "Initial_2": @xml_document.at("Secondary TaxpayerName MiddleInitial")&.text,
        "SPOUSE Last name_2": @xml_document.at("Secondary TaxpayerName LastName")&.text,
        "Spouse social security 1": @xml_document.at("Secondary TaxpayerSSN")&.text,
        "No. regular dependents": @xml_document.at("Form502B Dependents CountRegular")&.text,
        "No. 65orOver dependents": @xml_document.at("Form502B Dependents CountOver65")&.text,
        "No. total dependents": @xml_document.at("Form502B Dependents Count")&.text,
      }

      @intake.dependents.each_with_index do |dependent, i|
        answers["First Name #{i + 1}"] = dependent.first_name
        answers["MI #{i + 1}"] = dependent.middle_initial
        answers["Last Name #{i + 1}"] = dependent.last_name
        answers["DEPENDENTS SSN #{i + 1}"] = dependent.ssn
        answers["RELATIONSHIP #{i + 1}"] = dependent.relationship
        answers["REGULAR #{i + 1}"] = "Yes"
        answers["65 OR OLDER #{i + 1}"] = dependent.senior? ? "2" : "Off"
        dob_field_name = i.zero? ? "DOB date 1_af_date" : "DOB date 1_af_date #{i + 1}"
        answers[dob_field_name] = dependent.dob
      end
      
      answers
    end
  end
end
