module PdfFiller
  class Id39rAdditionalDependentsPdf
    include PdfHelper

    def source_pdf_name
      "idform39r-TY2024"
    end

    def initialize(submission, kwargs)
      @submission = submission
      @kwargs = kwargs

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:id)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      dependents = @kwargs[:dependents]
      answers = {}
      dependents.each_with_index do |dependent, index|
        answers.merge!(
          "FR#{index+1}FirstName" => dependent.first_name,
          "FR#{index+1}LastName" => dependent.last_name,
          "FR#{index+1}SSN" => dependent.ssn,
          "FR#{index+1}Birthdate" => dependent.dob.strftime('%m/%d/%Y'),
          )
      end
      answers
    end
  end
end