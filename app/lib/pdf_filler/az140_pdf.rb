module PdfFiller
  class Az140Pdf
    include PdfHelper

    def source_pdf_name
      "az140-TY2023"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:az)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      answers = {
        "1a" => [@xml_document.at('Primary TaxpayerName FirstName')&.text, @xml_document.at('Primary TaxpayerName MiddleInitial')&.text].join(' '),
        "1b" => [@xml_document.at('Primary TaxpayerName LastName')&.text, @xml_document.at('Primary TaxpayerName NameSuffix')&.text].join(' '),
        "1c" => @xml_document.at('Primary TaxpayerSSN')&.text,
        "1d" => spouse_first_name,
        "1e" => [@xml_document.at('Secondary TaxpayerName LastName')&.text, @xml_document.at('Secondary TaxpayerName NameSuffix')&.text].join(' '),
        "1f" => @xml_document.at('Secondary TaxpayerSSN')&.text,
        "2a" => @xml_document.at("USAddress AddressLine1Txt")&.text,
        "2c" => @xml_document.at("USPhone")&.text,
        "City, Town, Post Office" => @xml_document.at("CityNm")&.text,
        "State" => @xml_document.at("StateAbbreviationCd")&.text,
        "ZIP Code" => @xml_document.at("ZIPCd")&.text,
        "Last Names 4 years" => @xml_document.at('LNPriorYrs')&.text,
        "Filing Status" => filing_status,
        "Head of Household" => [@xml_document.at('QualChildDependentName FirstName')&.text, @xml_document.at('QualChildDependentName LastName')&.text].join(' '),
        "8" => @xml_document.at("AgeExemp")&.text,
        "9" => @xml_document.at("VisionExemp")&.text,
        "10a" => @xml_document.at("DependentsUnder17")&.text,
        "10b" => @xml_document.at("Dependents17AndOlder")&.text,
        "11a" => @xml_document.at("QualifyingParentsAncestors")&.text
      }

      non_qualifying_ancestor_dependents = @submission.data_source.dependents.reject(&:is_qualifying_parent_or_grandparent?)
      if non_qualifying_ancestor_dependents.count > 14
        # 14 is the 3 on page 1 plus the 11 extra rows on page 4
        raise "Can't handle this many dependents for Form 140!"
      elsif non_qualifying_ancestor_dependents.count > 3
        answers["10a_10b check box"] = "Yes"
      end

      non_qualifying_ancestor_dependents.each_with_index do |dependent, index|
        # PDF fields seem to be named consistently (10c ... 10p) whether they are on Page 1 or Page 4
        prefix = "10#{('c'..'p').to_a[index]}"
        answers.merge!(
          "#{prefix} First" => dependent.first_name,
          "#{prefix} Last" => dependent.last_name,
          "#{prefix} SSN" => dependent.ssn.delete('-'),
          "#{prefix} Relationship" => dependent.relationship_label,
          "#{prefix} Mo in Home" => dependent.months_in_home,
          "#{prefix}_10a check box" => dependent.under_17? ? "Yes" : nil,
          "#{prefix}_10b check box" => dependent.under_17? ? nil : "Yes",
        )
      end

      qualifying_ancestors = @submission.data_source.dependents.select(&:is_qualifying_parent_or_grandparent?)
      if qualifying_ancestors.count > 8
        # 8 is the 2 on page 1 plus the 6 extra rows on page 4
        raise "Can't handle this many qualifying ancestor dependents for Form 140!"
      elsif qualifying_ancestors.count > 2
        answers["11a check box"] = "Yes"
      end

      qualifying_ancestors.each_with_index do |dependent, index|
        # PDF fields seem to be named consistently (11b ... 11i) whether they are on Page 1 or Page 4
        prefix = "11#{('b'..'i').to_a[index]}"
        answers.merge!(
          "#{prefix} First" => dependent.first_name,
          "#{prefix} Last" => dependent.last_name,
          "#{prefix} SSN" => dependent.ssn.delete('-'),
          "#{prefix} Relationship" => dependent.relationship_label,
          "#{prefix} Mo in Home" => dependent.months_in_home,
          "#{prefix} over 65" => "Yes", # all of these dependents are 65 or older
          "#{prefix} died" => dependent.passed_away_yes? ? "Yes" : nil,
        )
      end

      answers.merge!({
        "12" => @xml_document.at('FedAdjGrossIncome')&.text,
        "14" => @xml_document.at('ModFedAdjGrossInc')&.text,
        "19" => @xml_document.at('AzAdjSubtotal')&.text,
        "28" => @xml_document.at("Subtractions IntUSObligations")&.text,
        "29a" => @xml_document.at('ExecFedStateLocGovPen')&.text,
        "29b" => @xml_document.at('SubExclBenAnnPen')&.text,
        "30" => @xml_document.at('USSSRailRoadBnft')&.text,
        "31" => @xml_document.at('WageAmIndian')&.text,
        "32" => @xml_document.at('CompNtnlGrdArmdFrcs')&.text,
        "35" => @xml_document.at('TotalSubtractions')&.text,
        "37" => @xml_document.at('Form140/Subtotal')&.text,
        "38" => @xml_document.at('AzSubtrAmts/ExemAmtAge65OrOver')&.text,
        "39" => @xml_document.at('AzSubtrAmts/ExemAmtBlind')&.text,
        "41" => @xml_document.at('AzSubtrAmts/ExemAmtParentsAncestors')&.text,
        "42" => @xml_document.at('AZAdjGrossIncome')&.text,
        "Itemized/Standard" => 'Choice2',
        "44C" => charitable_contributions,
        "53" => @xml_document.at('AzIncTaxWithheld')&.text,
        "56" => @xml_document.at('IncrExciseTaxCr')&.text,
        "59" => @xml_document.at('TotalPayments')&.text,
        "60" => @xml_document.at('TaxDue')&.text,
        "61" => @xml_document.at('OverPaymentOfTax')&.text,
        "63" => @xml_document.at('OverPaymentBalance')&.text,
        "79" => @xml_document.at('RefundAmt')&.text,
        "80" => @xml_document.at('AmtOwed')&.text
      })

      if @xml_document.at('RefundAmt')&.text.present?
        answers.merge!({
          "Refund" => refund_account_type,
          "Routing Number" => @xml_document.at('RoutingTransitNumber')&.text,
          "Account Number" => @xml_document.at('BankAccountNumber')&.text
        })
      end

      @deductions = @xml_document.at('Form140 DeductionAmt')

      answers.merge!({
        "43" => @deductions.at('AZDeductions')&.text,
        "45" => @deductions.at('AZTaxableInc')&.text,
        "46" => @deductions.at('ComputedTax')&.text,
        "48" => @deductions.at('SubTotal')&.text,
        "49" => @deductions.at('DepTaxCredit')&.text,
        "50" => @deductions.at('FamilyIncomeTaxCredit')&.text,
        "51" => @deductions.at('CreditsFromAZ301')&.text,
        "52" => @deductions.at('BalanceOfTaxDue')&.text,
     })

      @charitable_deductions = @xml_document.at('ClaimCharitableDed')
      answers.merge!({
        "3_1c" => @charitable_deductions&.at('GiftByCashOrCheck')&.text,
        "3_2c" => @charitable_deductions&.at('OtherThanCashOrCheck')&.text,
        "3_3c" => @charitable_deductions&.at('CarrPriorYear')&.text,
        "3_4c" => @charitable_deductions&.at('SubTotalContributions')&.text,
        "3_5c" => @charitable_deductions&.at('TotalContributions')&.text,
        "3_6c" => @charitable_deductions&.at('SubTotal')&.text,
        "3_7c" => @charitable_deductions&.at('IncreaseStdDed TotalIncStdDeduction')&.text,
        "44" => @xml_document.at('IncreaseStdDed TotalIncStdDeduction')&.text,
      })

      direct_file_data = @submission.data_source.direct_file_data
      answers.merge!({
        "81" => direct_file_data.primary_occupation,
        "82" => direct_file_data.spouse_occupation,
      })

      answers["SpouseSignature"] = "Filing as surviving spouse" if @submission.data_source.spouse_deceased?

      answers
    end

    private

    def calculated_fields
      @calculated_fields ||= @submission.data_source.tax_calculator.calculate
    end

    FILING_STATUS_OPTIONS = {
      "MarriedJoint" => 'Choice1',
      "HeadHousehold" => 'Choice2', # Qualifying Widow based state_file_az_intake#filing_status
      "MarriedFilingSeparateReturn" => 'Choice3',
      "Single" => 'Choice4',
    }

    def filing_status
      FILING_STATUS_OPTIONS[@xml_document.at('FilingStatus')&.text]
    end

    def spouse_first_name
      name = [@xml_document.at('Secondary TaxpayerName FirstName')&.text, @xml_document.at('Secondary TaxpayerName MiddleInitial')&.text].join(' ')
      if @submission.data_source.spouse_deceased?
        dod = Date.parse(@submission.data_source.direct_file_data.spouse_date_of_death)&.strftime("%-m/%-d/%Y")
        name = name + " Deceased #{dod}" if dod.present?
      end

      name
    end

    def charitable_contributions
      if @xml_document.at('CharitableDeduction')&.text == 'X'
        'Yes'
      else
        "Off"
      end
    end

    def refund_account_type
      if @xml_document.at('RefundAmt').present?
        case @submission.data_source.account_type
        when 'checking'
          'Checking Acct'
        when 'savings'
          'Savings Acct'
        end
      end
    end
  end
end
