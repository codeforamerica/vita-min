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
      primary = @intake.primary
      name = primary.full_name
      if @intake.filing_status_mfj?
        name = "#{name} and #{@intake.spouse.full_name}"
      end
      answers = {
        "Names as shown on returnRow1": name,
        "Social Security NumberRow1": primary.ssn
      }
      answers.merge!(dependents_info) if @intake.dependents.length > @dependent_offset
      answers
    end

    private

    def dependents_info
      answers = {}
      @intake.dependents[@dependent_offset..][..7].each_with_index do |dependent, index|
        answers["First nameRow#{index + 1}"] = dependent.first_name
        answers["MIRow#{index + 1}"] = dependent.middle_initial
        answers["Last nameRow#{index + 1}"] = dependent.last_name
        answers["RelationshipRow#{index + 1}"] = dependent.relationship_label || dependent.relationship.delete(" ")
        answers["SSN or ITINRow#{index + 1}"] = dependent.ssn
        answers["Date of birthRow#{index + 1}"] = dependent.dob.strftime("%Y-%m-%d")
      end
      answers
    end
  end
end
