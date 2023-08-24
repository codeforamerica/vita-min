class Irs1040ScheduleLepPdf
  include PdfHelper

  def source_pdf_name
    "tax_documents/f1040lep2021"
  end

  def initialize(submission)
    @xml_document = SubmissionBuilder::Ty2021::Documents::ScheduleLep.new(submission).document
  end

  def hash_for_pdf
    {
        PersonNm: @xml_document.at("PersonNm")&.text,
        SSN: @xml_document.at("SSN")&.text,
        LanguagePreferenceCd: @xml_document.at("LanguagePreferenceCd")&.text
    }
  end
end