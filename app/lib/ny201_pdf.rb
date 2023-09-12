class Ny201Pdf
  include PdfHelper

  def source_pdf_name
    "it201-TY2022"
  end

  def initialize(submission)
    @submission = submission

    # Most PDF fields are grabbed right off the XML
    @xml_document = SubmissionBuilder::Ty2022::States::Ny::IndividualReturn.new(submission).document
  end

  def hash_for_pdf
    answers = {
      TP_first_name: @xml_document.at('tiPrime FIRST_NAME')&.text
    }
    answers
  end
end
