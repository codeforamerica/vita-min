module PdfFiller
  class Md502Pdf
    include PdfHelper

    def source_pdf_name
      "md502-TY2023"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:md)
      @xml_document = builder.new(submission).document
      @calculator = submission.data_source.tax_calculator
      @calculator.calculate
    end

    def hash_for_pdf
      {
        "Enter 1" => @xml_document.at("Form502 Income FederalAdjustedGrossIncome")&.text,
        "Enter 1a" => @xml_document.at("Form502 Income WagesSalariesAndTips")&.text,
        "Enter 1b" => @xml_document.at("Form502 Income EarnedIncome")&.text,
        "Enter 1dEnter 1d" => @xml_document.at("Form502 Income TaxablePensionsIRAsAnnuities")&.text,
        "Enter Y of income more than $11,000" => @xml_document.at("Form502 Income InvestmentIncomeIndicator")&.text == "X" ? "Y" : ""
      }
    end
  end
end
