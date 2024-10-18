module PdfFiller
  class Md502CrPdf
    include PdfHelper

    def source_pdf_name
      "md502CR-TY2023"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:md)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      {
        'Text Field 1': @submission.data_source.primary.ssn,
        'Text Field 2': @submission.data_source.spouse.ssn,
        'Text Field 3': @submission.data_source.primary.first_name,
        'Text Field 4': @submission.data_source.primary.middle_initial,
        'Text Field 5': @submission.data_source.primary.last_name,
        'Text Field 6': @submission.data_source.spouse.first_name,
        'Text Field 7': @submission.data_source.spouse.middle_initial,
        'Text Field 8': @submission.data_source.spouse.last_name,
        'Text Field 27': @xml_document.at('Form502CR ChildAndDependentCare FederalAdjustedGrossIncome')&.text,
        'Text Field 115': @xml_document.at('Form502CR ChildAndDependentCare FederalChildCareCredit')&.text,
        'Text Field 29': @xml_document.at('Form502CR ChildAndDependentCare DecimalAmount')&.text,
        'Text Field 30': @xml_document.at('Form502CR ChildAndDependentCare Credit')&.text,
        'Text Field 1051': @xml_document.at('Form502CR Senior Credit')&.text
      }
    end
  end
end
