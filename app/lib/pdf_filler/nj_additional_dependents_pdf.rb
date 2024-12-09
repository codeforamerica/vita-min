module PdfFiller
  class NjAdditionalDependentsPdf
    include PdfHelper
    include StateFile::NjPdfHelper

    def source_pdf_name
      "nj_additional_dependents"
    end

    def initialize(submission)
      @submission = submission

      builder = StateFile::StateInformationService.submission_builder_class(:nj)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      answers = {
        "Names(s) as shown on NJ 1040": get_name(@xml_document),
        "Social Security Number": get_taxpayer_ssn
      }

      answers.merge!(fill_dependents)
      answers
    end

    private

    def get_dependents
      @xml_document.css("Dependents").map do |dependent|
        {
          first_name: dependent.at("DependentsName FirstName")&.text,
          last_name: dependent.at("DependentsName LastName")&.text,
          middle_initial: dependent.at("DependentsName MiddleInitial")&.text,
          suffix: dependent.at("DependentsName NameSuffix")&.text,
          ssn: dependent.at("DependentsSSN")&.text,
          birth_year: dependent.at("BirthYear")&.text,
        }
      end
    end

    def get_taxpayer_ssn
      @xml_document.at("ReturnHeaderState Filer Primary TaxpayerSSN")&.text
    end


    def fill_dependents
      answers = {}
      get_dependents[4..].each.with_index do |dependent, index|
        answers["Name_Row#{index + 1}"] = format_name(dependent[:first_name], dependent[:last_name], dependent[:middle_initial], dependent[:suffix])
        answers["SSN_Row#{index + 1}"] = dependent[:ssn]
        answers["BirthYear_Row#{index + 1}"] = dependent[:birth_year]
      end
      answers
    end
  end
end
