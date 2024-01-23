module PdfFiller
  class It201AdditionalDependentsPdf
    include PdfHelper
    attr_accessor :dependent_offset, :intake, :source_pdf_name

    def initialize(submission, dependent_offset: 7, source_pdf_name: "it201_additional_dependents")
      @intake = submission.data_source
      @dependent_offset = dependent_offset
      @source_pdf_name = source_pdf_name
    end

    def hash_for_pdf
      answers = {}
      answers.merge!(dependents_info) if @intake.dependents.length > @dependent_offset
      answers
    end

    private

    def dependents_info
      answers = {}
      @intake.dependents[@dependent_offset..].each_with_index do |dependent, index|
        answers["first_name_#{index + 1}"] = dependent.first_name
        answers["mi_#{index + 1}"] = dependent.middle_initial
        answers["last_name_#{index + 1}"] = dependent.last_name
        answers["relationship_#{index + 1}"] = dependent.relationship.delete(" ")
        answers["ssn_or_itin_#{index + 1}"] = dependent.ssn
        answers["date_of_birth_#{index + 1}"] = dependent.dob.strftime("%Y-%m-%d")
      end
      answers
    end
  end
end
