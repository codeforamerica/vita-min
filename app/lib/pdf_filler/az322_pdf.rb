module PdfFiller
  class Az322Pdf
    include PdfHelper

    def source_pdf_name
      "az322-TY2023"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:az)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      answers = {
        "TP_Name" => [@xml_document.at('Primary TaxpayerName FirstName')&.text, @xml_document.at('Primary TaxpayerName MiddleInitial')&.text, @xml_document.at('Primary TaxpayerName LastName')&.text, @xml_document.at('Primary TaxpayerName NameSuffix')&.text].join(' '),
        "TP_SSN" => @xml_document.at('Primary TaxpayerSSN')&.text,
        "Spouse_Name" => [@xml_document.at('Secondary TaxpayerName FirstName')&.text, @xml_document.at('Secondary TaxpayerName MiddleInitial')&.text, @xml_document.at('Secondary TaxpayerName LastName')&.text, @xml_document.at('Secondary TaxpayerName NameSuffix')&.text].join(' '),
        "Spouse_SSN" => @xml_document.at('Secondary TaxpayerSSN')&.text,
        "4" => @xml_document.at('TotalContributionsContSheet')&.text,
        "5" => @xml_document.at('TotalContributions')&.text,
        "9" => '0',
        "10" => '0',
        "11" => @xml_document.at('SubTotalAmt')&.text,
        "12" => @xml_document.at('SingleHOH')&.text,
        "13" => @xml_document.at('CurrentYrCr')&.text,
        "20" => @xml_document.at('CurrentYrCr')&.text,
        "22" => @xml_document.at('TotalAvailCr')&.text,
        "4h" => @xml_document.at('TotalContributionsContSheet')&.text,
      }
      @submission.data_source.az322_contributions.each_with_index do |contribution, index|
        if index < 3
          prefix = (index + 1).to_s
        else
          letter = ('a'..'g').to_a[index - 3]
          prefix = "4#{letter}"
        end
        answers["#{prefix}a"] = contribution.date_of_contribution.strftime("%m%d")
        answers["#{prefix}b"] = contribution.ctds_code
        answers["#{prefix}c"] = contribution.school_name
        answers["#{prefix}d"] = contribution.district_name
        answers["#{prefix}e"] = contribution.amount.round
      end

      answers
    end
  end
end
