module PdfFiller
  class Az8879Pdf
    include PdfHelper

    def source_pdf_name
      "az8879-TY2024"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:az)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      answers = {
        "Your First Name and Initial" => @submission.data_source.primary.first_name_and_middle_initial,
        "Your Last Name" => @submission.data_source.primary.last_name_and_suffix,
        "Your SSN" => @submission.data_source.primary.ssn,
        "Spouse First Name and Initial" => @submission.data_source.spouse.first_name_and_middle_initial,
        "Spouse Last Name" => @submission.data_source.spouse.last_name_and_suffix,
        "Spouse SSN" => @submission.data_source.spouse.ssn,
        "1 AZ AGI" => @xml_document.at('AZAdjGrossIncome')&.text,
        "2 Balance of Tax" => @xml_document.at("BalanceOfTaxDue")&.text,
        "3 AZ Income Tax Withheld" => @xml_document.at("AzIncTaxWithheld")&.text,
      }

      if @xml_document.at('RefundAmt').present?
        answers["4 Refund Checkbox"] = 'Yes'
        answers["4 Refund Amount"] = @xml_document.at("RefundAmt")&.text
      elsif @xml_document.at('AmtOwed').present?
        answers["5 Owed Checkbox"] = 'Yes'
        answers["5 Owed Amount"] = @xml_document.at("AmtOwed")&.text
      end

      # Foreign Accounts are not supported
      case @submission.data_source.account_type
      when 'checking'
        answers['Account Type Checkbox - Checking'] = 'Yes'
      when 'savings'
        answers['Account Type Checkbox - Savings'] = 'Yes'
      end
      
      answers.merge!(
        "Routing Number" => @submission.data_source.routing_number,
        "Account Number" => @submission.data_source.account_number,
        "Direct Debit Date" => @submission.data_source.date_electronic_withdrawal&.strftime("%m%d%Y"),
        "Direct Debit Amount" => @submission.data_source.withdraw_amount,
        "Electronic Return Originator" => 'FileYourStateTaxes'
      )

      if @xml_document.at('RefundAmt').present?
        answers["6a Checkbox"] = 'Yes'
      elsif @xml_document.at('AmtOwed').present?
        answers["6b Checkbox"] = 'Yes'
        answers["6c Checkbox"] = 'Yes'
      end

      answers
    end
  end
end
