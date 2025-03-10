module PdfFiller
  class Az301Pdf
    include PdfHelper

    def source_pdf_name
      "az301-TY2024"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:az)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      {
        "Tp_Name" => @submission.data_source.primary.full_name,
        "Tp_SSN" => @submission.data_source.primary.ssn,
        "Spouse_Name" => @submission.data_source.spouse.full_name,
        "Spouse_SSN" => @submission.data_source.spouse.ssn,
        "6a" => @xml_document.at('ColumnA CtrbChrtyPrvdAstWrkgPor')&.text,
        "6c" => @xml_document.at('ColumnC CtrbChrtyPrvdAstWrkgPor')&.text,
        "7a" => @xml_document.at('ColumnA CtrbMdFePdPblcSchl')&.text,
        "7c" => @xml_document.at('ColumnC CtrbMdFePdPblcSchl')&.text,
        "25" => @xml_document.at('ColumnC TotalAvailTaxCr')&.text,
        "27" => @xml_document.at('ComputedTax')&.text,
        "32" => @xml_document.at('AppTaxCr Subtotal')&.text,
        "33" => @xml_document.at('FamilyIncomeTax')&.text,
        "34" => @xml_document.at('DiffFamilyIncTaxSubTotal')&.text,
        "40" => @xml_document.at('NonrefunCreditsUsed CtrbChrtyPrvdAstWrkgPor')&.text,
        "41" => @xml_document.at('NonrefunCreditsUsed CtrbMdFePdPblcSchl')&.text,
        "60" => @xml_document.at('TxCrUsedForm301')&.text,
        "62" => @xml_document.at('TxCrUsedForm301')&.text,
      }
    end
  end
end
