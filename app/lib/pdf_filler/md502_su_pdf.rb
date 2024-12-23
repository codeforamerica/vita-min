module PdfFiller
  class Md502SuPdf
    include PdfHelper

    def source_pdf_name
      "md502SU-TY2024"
    end

    def initialize(submission)
      @submission = submission
      builder = StateFile::StateInformationService.submission_builder_class(:md)
    end

    def hash_for_pdf
      {
        'Your First Name' => @submission.data_source.primary.first_name,
        'Text1' => @submission.data_source.primary.middle_initial,
        'Your Last Name' => @submission.data_source.primary.last_name,
        'Your Social Security Number' => @submission.data_source.primary.ssn,
        'Spouses First Name' => @submission.data_source.spouse.first_name,
        'Text2' => @submission.data_source.spouse.middle_initial,
        'Spouses Last Name' => @submission.data_source.spouse.last_name,
        'Spouses Social Security Number' => @submission.data_source.spouse.ssn,
        'ab Income from US Government obligations See Instruction 13                         ab' => calculated_fields.fetch(:MD502_SU_LINE_AB),
        'appropriate code letters                                                  TOTAL 1' => calculated_fields.fetch(:MD502_SU_LINE_1),
        'NAME' => @submission.data_source.primary.last_name,
        'SSN' => @submission.data_source.primary.ssn,
        'NAME_2' => @submission.data_source.primary.last_name,
        'SSN_2' => @submission.data_source.primary.ssn,
      }
    end

    private

    def calculated_fields
      @calculated_fields ||= @submission.data_source.tax_calculator.calculate
    end
  end
end
