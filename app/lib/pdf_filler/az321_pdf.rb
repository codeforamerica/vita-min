class PdfFiller::Az321Pdf
  include PdfHelper

  def source_pdf_name
    "az321-TY2023"
  end

  def initialize(submission)
    @submission = submission

    builder = StateFile::StateInformationService.submission_builder_class(:az)
    @xml_document = builder.new(submission).document
  end

  def hash_for_pdf
    answers = {
      "FY_Beg" => "0101",
      "FY_End" => "1231#{MultiTenantService.new(:statefile).current_tax_year}",
      "TP_Name" => name('Primary'),
      "TP_SSN" => @xml_document.at('Primary TaxpayerSSN')&.text,
      "Spouse_Name" => name('Secondary'),
      "Spouse_SSN" => @xml_document.at('Secondary TaxpayerSSN')&.text,
      "4h" => @xml_document.at('ContTotalCharityAmt')&.text,
      "4" => @xml_document.at('TotalCharityAmtContSheet')&.text,
      "5" => @xml_document.at('TotalCharityAmt')&.text,
      "11" => @xml_document.at('AddCurYrCrAmtTotCshCont')&.text,
      "12" => @xml_document.at('TxPyrsStatus')&.text,
      "13" => @xml_document.at('TotCshContrFostrChrty')&.text,
      "20" => @xml_document.at('CurrentYrCr')&.text,
      "22" => @xml_document.at('TotalAvailCr')&.text,
    }

    @submission.data_source.az321_contributions.each_with_index do |contribution, index|
      break if index >= 10

      if index <= 2
        prefix = index + 1
      else
        letter = ('a'..'g').to_a[index - 3]
        prefix = "4#{letter}"
      end

      answers["#{prefix}a"] = contribution.date_of_contribution.strftime("%m%d")
      answers["#{prefix}b"] = contribution.charity_code
      answers["#{prefix}c"] = contribution.charity_name
      answers["#{prefix}d"] = contribution.amount.round
    end

    answers
  end

  private

  def name(taxpayer)
    [
      @xml_document.at("#{taxpayer} TaxpayerName FirstName")&.text,
      @xml_document.at("#{taxpayer} TaxpayerName MiddleInitial")&.text,
      @xml_document.at("#{taxpayer} TaxpayerName LastName")&.text,
      @xml_document.at("#{taxpayer} TaxpayerName NameSuffix")&.text
    ].join(' ')
  end
end
