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
        "Tp_Name" => [@xml_document.at('Primary TaxpayerName FirstName')&.text, @xml_document.at('Primary TaxpayerName MiddleInitial')&.text, @xml_document.at('Primary TaxpayerName LastName')&.text, @xml_document.at('Primary TaxpayerName NameSuffix')&.text].join(' '),
        "Tp_SSN" => @xml_document.at('Primary TaxpayerSSN')&.text,
        "Spouse_Name" => [@xml_document.at('Secondary TaxpayerName FirstName')&.text, @xml_document.at('Secondary TaxpayerName MiddleInitial')&.text, @xml_document.at('Secondary TaxpayerName LastName')&.text, @xml_document.at('Secondary TaxpayerName NameSuffix')&.text].join(' '),
        "Spouse_SSN" => @xml_document.at('Secondary TaxpayerSSN')&.text,
        "6a" => @xml_document.at('ColumnA CtrbChrtyPrvdAstWrkgPor')&.text,
        "6c" => @xml_document.at('ColumnC CtrbChrtyPrvdAstWrkgPor')&.text,
        "7a" => @xml_document.at('ColumnA CtrbMdFePdPblcSchl')&.text,
        "7c" => @xml_document.at('ColumnC CtrbMdFePdPblcSchl')&.text,
        "26" => @xml_document.at('ColumnC TotalAvailTaxCr')&.text,
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
