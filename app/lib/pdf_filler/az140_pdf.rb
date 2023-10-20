module PdfFiller
  class Az140Pdf
    include PdfHelper

    def source_pdf_name
      "az140-TY2022"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      @xml_document = SubmissionBuilder::Ty2022::States::Az::IndividualReturn.new(submission).document
    end

    def hash_for_pdf
      answers = {
        # TODO: name information doesn't seem to exist in AZ schema, just NameControl
        "1a" => [@xml_document.at('Primary TaxpayerName FirstName')&.text, @xml_document.at('Primary TaxpayerName MiddleInitial')&.text].join(' '), # middle initial?
        "1b" => @xml_document.at('Primary TaxpayerName LastName')&.text,
        "1c" => @xml_document.at('Primary TaxpayerSSN')&.text,
        "1d" => [@xml_document.at('Secondary TaxpayerName FirstName')&.text, @xml_document.at('Secondary TaxpayerName MiddleInitial')&.text].join(' '),
        "1e" => @xml_document.at('Secondary TaxpayerName LastName')&.text,
        "1f" => @xml_document.at('Secondary TaxpayerSSN')&.text,
        "2a" => @xml_document.at("USAddress AddressLine1Txt")&.text,
        "2c" => @xml_document.at("USPhone")&.text,
        "City, Town, Post Office" => @xml_document.at("CityNm")&.text,
        "State" => @xml_document.at("StateAbbreviationCd")&.text,
        "ZIP Code" => @xml_document.at("ZIPCd")&.text,
        "Filing Status" => filing_status,
        "8" => calculated_fields.fetch(:AMT_8),
        "9" => calculated_fields.fetch(:AMT_9),
        "10a" => "TODO",
        "10b" => "TODO",
        "11a" => "TODO",
        "10d First" => "TODO",
        "10e First" => "TODO",
        "10d Last" => "TODO",
        "10e Last" => "TODO",
        "10d SSN" => "TODO",
        "10e SSN" => "TODO",
        "10d Relationship" => "TODO",
        "10e Relationship" => "TODO",
        "10d Mo in Home" => "TODO",
        "10e Mo in Home" => "TODO",
        "10d_10a check box" => "TODO",
        "10e_10a check box" => "TODO",
        "10d_10b check box" => "TODO",
        "10e_10b check box" => "TODO",
        "10d educ" => "TODO",
        "10e educ" => "TODO",
        "11c First" => "TODO",
        "11c Last" => "TODO",
        "11c SSN" => "TODO",
        "11c Relationship" => "TODO",
        "11c died" => "TODO",
        "11a check box" => "TODO",
        "19" => @xml_document.at('AzAdjSubtotal')&.text,
        "12" => @xml_document.at('FedAdjGrossIncome')&.text,
        "14" => @xml_document.at('ModFedAdjGrossInc')&.text,
        "30" =>  @xml_document.at('USSSRailRoadBnft')&.text,
        "43" =>  @xml_document.at('AZDeductions')&.text,
        "44" =>  @xml_document.at('ClaimCharitableDed')&.text,
        "45" =>  @xml_document.at('AZTaxableInc')&.text,
        "46" =>  @xml_document.at('ComputedTax')&.text,
        "48" =>  @xml_document.at('SubTotal')&.text,
        "49" =>  @xml_document.at('DepTaxCredit')&.text,
        "50" =>  @xml_document.at('FamilyIncomeTaxCredit')&.text,
        "52" =>  @xml_document.at('BalanceOfTaxDue')&.text,
        "53" =>  @xml_document.at('TotalPaymentAndCreditsType')&.text,
        "56" =>  @xml_document.at('IncrExciseTaxCr')&.text,
      }
      answers
    end

    private

    def calculated_fields
      @calculated_fields ||= @submission.data_source.tax_calculator.calculate
    end
    
    FILING_STATUS_OPTIONS = {
      "MarriedJoint" => 'Choice1',
      "HeadHousehold" => 'Choice2',
      "MarriedFilingSeparateReturn" => 'Choice3',
      "Single" => 'Choice4',
    }

    def filing_status
      FILING_STATUS_OPTIONS[@xml_document.at('FilingStatus')&.text]
    end
  end
end
