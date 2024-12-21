module PdfFiller
  class Md502CrPdf
    include PdfHelper

    def source_pdf_name
      "md502CR-TY2024"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:md)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      {
        'Your Social Security Number': @submission.data_source.primary.ssn,
        'Spouses Social Security Number': @submission.data_source.spouse.ssn,
        'Your First Name': @submission.data_source.primary.first_name,
        'Primary MI': @submission.data_source.primary.middle_initial,
        'Your Last Name': @submission.data_source.primary.last_name,
        'Spouses First Name': @submission.data_source.spouse.first_name,
        'Spouse MI': @submission.data_source.spouse.middle_initial,
        'Spouses Last Name': @submission.data_source.spouse.last_name,
        'Text Field 27': @xml_document.at('Form502CR ChildAndDependentCare FederalAdjustedGrossIncome')&.text,
        'Text Field 115': @xml_document.at('Form502CR ChildAndDependentCare FederalChildCareCredit')&.text,
        'Text Field 29': @xml_document.at('Form502CR ChildAndDependentCare DecimalAmount')&.text,
        'Text Field 30': @xml_document.at('Form502CR ChildAndDependentCare Credit')&.text,
        '1_9': @xml_document.at('Form502CR Senior Credit')&.text,
        'Text Field 1049': @xml_document.at('Form502CR Summary ChildAndDependentCareCr')&.text,
        'Text Field 1039': @xml_document.at('Form502CR Summary SeniorCr')&.text,
        'Text Field 1038': @xml_document.at('Form502CR Summary TotalCredits')&.text,
        '7_2': @xml_document.at('Form502CR Refundable ChildAndDependentCareCr')&.text,
        '8_2': @xml_document.at('Form502CR Refundable MDChildTaxCr')&.text,
        '10': @xml_document.at('Form502CR Refundable TotalCredits')&.text,
      }
    end
  end
end
