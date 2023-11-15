module PdfFiller
  class Az8879Pdf
    include PdfHelper

    def source_pdf_name
      "az8879-TY2023"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      @xml_document = SubmissionBuilder::Ty2022::States::Az::IndividualReturn.new(submission).document
    end

    def hash_for_pdf
      {
        "Your First Name and Initial" => [@xml_document.at('Primary TaxpayerName FirstName')&.text, @xml_document.at('Primary TaxpayerName MiddleInitial')&.text].join(' '),
        "Your Last Name" => @xml_document.at('Primary TaxpayerName LastName')&.text,
        "Your SSN" => @xml_document.at('Primary TaxpayerSSN')&.text,
        "Spouse First Name and Initial" => [@xml_document.at('Secondary TaxpayerName FirstName')&.text, @xml_document.at('Secondary TaxpayerName MiddleInitial')&.text].join(' '),
        "Spouse Last Name" => @xml_document.at('Secondary TaxpayerName LastName')&.text,
        "Spouse SSN" => @xml_document.at('Secondary TaxpayerSSN')&.text,
        "1 AZ AGI" => @xml_document.at('AZAdjGrossIncome')&.text,
        "2 Balance of Tax" => @xml_document.at("BalanceOfTaxDue")&.text,
        "3 AZ Income Tax Withheld" => @xml_document.at("AzIncTaxWithheld")&.text,
        "4 Refund Checkbox" => @xml_document.at('RefundAmt').present? ? 'X' : '',
        "4 Refund Amount" => @xml_document.at('RefundAmt').present? ? @xml_document.at("RefundAmt")&.text : 0,
        "5 Owed Checkbox" => @xml_document.at('AmtOwed').present? ? 'X' : '',
        "5 Owed Amount" => @xml_document.at('AmtOwed').present? ? @xml_document.at("AmtOwed")&.text : 0,
        "Electronic Return Originator" => "Code for America Labs, Inc",
        "6a Refund Deposit Consent" => @submission.data_source.primary_esigned_yes? ? 'X' : '',
        "6b Refund Deposit Waiver" => @submission.data_source.primary_esigned_yes? ? 'X' : '',
        "6c Tax Withdrawal Consent" => @submission.data_source.primary_esigned_yes? ? 'X' : '',
        "Your Signature" => [@xml_document.at('Primary TaxpayerName FirstName')&.text, @xml_document.at('Primary TaxpayerName MiddleInitial')&.text, @xml_document.at('Primary TaxpayerName LastName')&.text].join(' '),
        "Your Date Signed" => strftime_date(@submission.data_source.primary_esigned_at),
        "Spouse Signature" => [@xml_document.at('Secondary TaxpayerName FirstName')&.text, @xml_document.at('Secondary TaxpayerName MiddleInitial')&.text, @xml_document.at('Secondary TaxpayerName LastName')&.text].join(' '),
        "Spouse Date Signed" => strftime_date(@submission.data_source.spouse_esigned_at),
        # TODO complete these fields when the banking/refund info is available
        # "Foreign Account Checkbox" => '',
        # "Type of Account Checkbox - Checking" => '',
        # "Type of Account Checkbox - Savings" => '',
        # "Routing Number" => '',
        # "Account Number" => '',
        # "Direct Debit Date" => '',
        # "Direct Debit Amount" => '',
      }
    end

    private

    def calculated_fields
      @calculated_fields ||= @submission.data_source.tax_calculator.calculate
    end
  end
end
