module PdfFiller
  class Ny213AttPdf
    include PdfHelper
    attr_accessor :start_node
    delegate :tax_year, to: :@submission

    def source_pdf_name
      "it213att-TY2023"
    end

    def nys_form_type
      "239"
    end

    def barcode_overlay_rect
      [[0, 26], 125, 29]
    end

    def initialize(submission, dependent_offset: nil)
      @submission = submission
      @intake = submission.data_source
      builder = SubmissionBuilder::StateFile.from_state_code(:ny)
      if dependent_offset.nil?
        dependent_offset = builder::DEPENDENT_OVERFLOW_THRESHOLD
      end
      @xml_document = builder.new(submission).document
      @dependent_offset = dependent_offset
    end

    def hash_for_pdf
      answers = {}
      answers["Name Shown on Return"] = names_on_return
      answers["Your SSN"] = @xml_document.at('EXT_TP_ID')&.text
      answers.merge!(dependents_info)
      answers
    end

    private

    def names_on_return
      primary_name = "#{@xml_document.at('tiPrime FIRST_NAME')&.text} #{@xml_document.at('tiPrime LAST_NAME')&.text}"
      if @intake.filing_status_mfj?
        spouse_name = "#{@xml_document.at('tiSpouse FIRST_NAME')&.text} #{@xml_document.at('tiSpouse LAST_NAME')&.text}"
        "#{primary_name} and #{spouse_name}"
      else
        primary_name
      end
    end

    def dependents_info
      answers = {}
      qualifying_dependents = @intake.dependents.select(&:eligible_for_child_tax_credit)[@dependent_offset..]
      qualifying_dependents.each_with_index do |dependent, index|
        answers["Last Name #{index + 1}"] = dependent.last_name
        answers["MI #{index + 1}"] = dependent.middle_initial
        answers["First Name #{index + 1}"] = dependent.first_name
        answers["SSN #{index + 1}"] = dependent.ssn
        answers["Year of Birth 1.#{index}"] = dependent.dob.strftime("%m%d%Y")
      end
      answers
    end
  end
end
