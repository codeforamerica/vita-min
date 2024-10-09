module PdfFiller
  class Md502bPdf
    include PdfHelper

    def source_pdf_name
      "md502B-TY2023"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:md)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      answers = {
        "No. regular dependents": @xml_document.at("Form502B Dependents CountRegular")&.text,
        "No. 65orOver dependents": @xml_document.at("Form502B Dependents CountOver65")&.text,
        "No. total dependents": @xml_document.at("Form502B Dependents Count")&.text,
      }

      dependent_attrs = @xml_document.at("Form502B Dependents").css("Dependent").each_with_index.reduce({}) do |acc, (dependent, i)|
        acc["First Name #{i + 1}"] = dependent.at("Name FirstName")&.text
        acc["MI #{i + 1}"] = dependent.at("Name MiddleInitial")&.text
        acc["Last Name #{i + 1}"] = dependent.at("Name LastName")&.text
        acc["DEPENDENTS SSN #{i + 1}"] = dependent.at("SSN")&.text
        acc["RELATIONSHIP #{i + 1}"] = dependent.at("RelationToTaxpayer")&.text
        acc["REGULAR #{i + 1}"] = "Yes"
        acc["65 OR OLDER #{i + 1}"] = xml_value_to_bool(dependent.at("Over65"), "CheckboxType") ? "2" : "Off"
        dob_field_name = i == 0 ? "DOB date 1_af_date" : "DOB date 1_af_date #{i + 1}"
        acc[dob_field_name] = dependent.at("DependentDOB")&.text
        acc
      end
      answers.merge!(dependent_attrs)

      answers
    end
  end
end
