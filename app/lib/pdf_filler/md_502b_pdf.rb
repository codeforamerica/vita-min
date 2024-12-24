module PdfFiller
  class Md502bPdf
    include PdfHelper

    def source_pdf_name
      "md502B-TY2024"
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
        'Your First Name': @xml_document.at("Primary TaxpayerName FirstName")&.text,
        'Primary MI': @xml_document.at("Primary TaxpayerName MiddleInitial")&.text,
        'Your Last Name': @xml_document.at("Primary TaxpayerName LastName")&.text,
        'Your Social Security Number': @xml_document.at("Primary TaxpayerSSN")&.text,
        'Spouses First Name': @xml_document.at("Secondary TaxpayerName FirstName")&.text,
        'Spouse MI': @xml_document.at("Secondary TaxpayerName MiddleInitial")&.text,
        'Spouses Last Name': @xml_document.at("Secondary TaxpayerName LastName")&.text,
        'Spouses Social Security Number': @xml_document.at("Secondary TaxpayerSSN")&.text,
        CountRegular: @xml_document.at("Form502B Dependents CountRegular")&.text,
        CountOver65: @xml_document.at("Form502B Dependents CountOver65")&.text,
        Count: @xml_document.at("Form502B Dependents Count")&.text,
      }

      @intake.dependents.first(12).each_with_index do |dependent, i|
        answers["First Name #{i + 1}"] = dependent.first_name
        answers["MI #{i + 1}"] = dependent.middle_initial
        answers["Last Name #{i + 1}"] = dependent.last_name
        answers["DEPENDENTS SSN #{i + 1}"] = dependent.ssn
        answers["RELATIONSHIP #{i + 1}"] = dependent.relationship
        answers["REGULAR #{i + 1}"] = "Yes"
        answers["65 OR OLDER #{i + 1}"] = dependent.senior? ? "2" : "Off"
        dob_field_name = i.zero? ? "DOB date 1_af_date" : "DOB date 1_af_date #{i + 1}"
        answers[dob_field_name] = dependent.dob.strftime("%m/%d/%Y")
        answers[HEALTH_INSURANCE_CHECKBOX_LABELS[i]] = dependent.md_did_not_have_health_insurance_yes? ? "Yes" : "Off"
      end
      answers
    end

    HEALTH_INSURANCE_CHECKBOX_LABELS = [
      "Check Box 1",
      "Check Box 2",
      "Check Box 3",
      "Check Box 4",
      "Check Box 6",
      "Check Box 5",
      "Check Box 1 7",
      "Check Box 1 8",
      "Check Box 1 9",
      "Check Box 10",
      "Check Box 11",
      "Check Box 1 12",
    ].freeze
  end
end
