module PdfFiller
  class F13614cPdf
    include PdfHelper

    GATES = {
      ever_owned_home: [
        :sold_a_home,
        :received_homebuyer_credit,
        :paid_mortgage_interest
      ],
      ever_married: [
        :paid_alimony,
        :divorced,
        :lived_with_spouse,
        :married,
        :received_alimony,
        :separated,
        :widowed
      ],
      had_dependents: [
        :adopted_child,
        :paid_dependent_care
      ],
      sold_assets: [
        :had_asset_sale_income,
        :reported_asset_sale_loss
      ],
      wants_to_itemize: [
        :paid_charitable_contributions,
        :had_gambling_income,
        :paid_local_tax,
        :had_local_tax_refund,
        :paid_medical_expenses,
        :paid_mortgage_interest,
        :paid_school_supplies
      ],
      had_social_security_or_retirement: [
        :paid_retirement_contributions,
        :had_retirement_income,
        :had_social_security_income
      ],
    }

    def source_pdf_name
      "f13614c-TY2024"
    end

    def document_type
      DocumentTypes::Form13614C
    end

    def output_filename
      "F13614-C"
    end

    def initialize(intake)
      @intake = intake
      @dependents = intake.dependents
    end

    def hash_for_pdf
      answers = {}
      answers.merge!(you_and_spouse_info)
      answers.merge!(dependents_info) if @dependents.present?
      answers.merge!(
        "form1[0].page1[0].mailingAddress[0]" => @intake.street_address,
        "form1[0].page1[0].maillingApartmentNumber[0]" => @intake.street_address2,
        "form1[0].page1[0].mailingCity[0]" => @intake.city,
        "form1[0].page1[0].mailingState[0]" => @intake.state&.upcase,
        "form1[0].page1[0].mailingZIPCode[0]" => @intake.zip_code,
      )
      answers.merge!(
        yes_no_checkboxes("form1[0].page1[0].q10CanAnyoneClaim[0]", @intake.claimed_by_another, include_unsure: true),
        yes_no_checkboxes("form1[0].page1[0].q11HaveYouOr[0]", collective_yes_no_unsure(@intake.issued_identity_pin, @intake.spouse_issued_identity_pin))
      )
      answers.merge!(
        keep_and_normalize({
          "form1[0].page1[0].maritalStatus[0].statusNeverMarried[0]" => @intake.ever_married_no?,
          "form1[0].page1[0].maritalStatus[0].statusMarried[0]" => (@intake.ever_married_yes? && @intake.married_yes? && @intake.separated_no?),
          "form1[0].page1[0].maritalStatus[0].statusLegallySeparated[0].statusLegallySeparated[0]" => (@intake.ever_married_yes? && @intake.separated_yes?),
          "form1[0].page1[0].maritalStatus[0].statusDivorced[0].statusDivorced[0]" => (@intake.ever_married_yes? && @intake.married_no? && @intake.divorced_yes?),
          "form1[0].page1[0].maritalStatus[0].marriedForAll[0].forAllYes[0]" => (@intake.married_yes? && @intake.got_married_during_tax_year_yes?),
          "form1[0].page1[0].maritalStatus[0].marriedForAll[0].forAllNo[0]" => (@intake.married_yes? && @intake.got_married_during_tax_year_no?),
          "form1[0].page1[0].maritalStatus[0].statusWidowed[0].statusWidowed[0]" => (@intake.ever_married_yes? && @intake.married_no? && @intake.widowed_yes?),
          "form1[0].page1[0].maritalStatus[0].liveWithSpouse[0].liveWithYes[0]" => (@intake.ever_married_yes? && @intake.lived_with_spouse_yes?),
          "form1[0].page1[0].maritalStatus[0].liveWithSpouse[0].liveWithNo[0]" => (@intake.married_yes? && @intake.lived_with_spouse_no?),
        })
      )

      answers["form1[0].page1[0].maritalStatus[0].statusLegallySeparated[0].dateSeparateDecree[0]"] = @intake.separated_year
      answers["form1[0].page1[0].maritalStatus[0].statusDivorced[0].dateFinalDecree[0]"] = @intake.divorced_year
      answers["form1[0].page1[0].maritalStatus[0].statusWidowed[0].yearSpousesDeath[0]"] = @intake.widowed_year

      answers.merge!(
        yes_no_checkboxes("form1[0].page1[0].q1AsOfDecember[0].q1aGetMarried[0]", @intake.got_married_during_tax_year),
        yes_no_checkboxes("form1[0].page1[0].q1AsOfDecember[0].q1bLiveWith[0]", fetch_gated_value(@intake, :lived_with_spouse)),
      )
      answers["form1[0].page1[0].additionalSpace[0].additionalSpace[0]"] = @dependents.length > 3 ? "1" : nil

      answers.merge!(
        keep_and_normalize({
          "form1[0].page2[0].receivedMoneyFrom[0].wagesPartFull[0]" => @intake.had_wages_yes?,
          "form1[0].page2[0].receivedMoneyFrom[0].receivedMoneyTimps[0]" => @intake.had_tips_yes?,
          "form1[0].page2[0].receivedMoneyFrom[0].retirementAccount[0]" => @intake.had_social_security_or_retirement_yes? && @intake.had_retirement_income_yes?,
          "form1[0].page2[0].receivedMoneyFrom[0].disabilityBenefits[0].disabilityBenefits[0]" => @intake.had_disability_income_yes?,
          "form1[0].page2[0].receivedMoneyFrom[0].socialSecurityRailroad[0]" => @intake.had_social_security_or_retirement_yes? && @intake.had_social_security_income_yes?,
          "form1[0].page2[0].receivedMoneyFrom[0].unemploymentBenefits[0]" => @intake.had_unemployment_income_yes?,
          "form1[0].page2[0].receivedMoneyFrom[0].refundStateLocal[0]" => @intake.wants_to_itemize_yes? && @intake.had_local_tax_refund_yes?,
          "form1[0].page2[0].receivedMoneyFrom[0].interestOrDividends[0]" => @intake.had_interest_income_yes?,
          "form1[0].page2[0].receivedMoneyFrom[0].saleStocksBonds[0]" => @intake.sold_assets_yes? && @intake.had_asset_sale_income_yes?,
          "form1[0].page2[0].receivedMoneyFrom[0].reportALoss[0].reportLossYes[0]" => @intake.sold_assets_yes? && @intake.reported_asset_sale_loss_yes?,
          "form1[0].page2[0].receivedMoneyFrom[0].reportALoss[0].reportLossNo[0]" => @intake.sold_assets_yes? && @intake.reported_asset_sale_loss_no?,
          "form1[0].page2[0].receivedMoneyFrom[0].receivedAlimony[0]" => @intake.ever_married_yes? && @intake.received_alimony_yes?,
          "form1[0].page2[0].receivedMoneyFrom[0].incomeRentingHouse[0].incomeRentingHouse[0]" => @intake.had_rental_income_yes?,
          "form1[0].page2[0].receivedMoneyFrom[0].gamblingLotteryWinnings[0]" => @intake.wants_to_itemize_yes? && @intake.had_gambling_income_yes?,
          "form1[0].page2[0].receivedMoneyFrom[0].paymentsContractSelf[0]" => @intake.had_self_employment_income_yes?,
          "form1[0].page2[0].receivedMoneyFrom[0].lossLastReturn[0].reportLossYes[0]" => @intake.reported_self_employment_loss_yes?,
          "form1[0].page2[0].receivedMoneyFrom[0].lossLastReturn[0].reportLossNo[0]" => @intake.reported_self_employment_loss_no?,
          "form1[0].page2[0].receivedMoneyFrom[0].otherMoneyReceived[0].otherMoneyReceived[0]" => @intake.had_other_income_yes?
        })
      )

      answers["form1[0].page2[0].receivedMoneyFrom[0].howManyJobs[0]"] = @intake.job_count.to_s

      answers.merge!(
        yes_no_checkboxes("form1[0].page2[0].Part3[0].q3Scholarships[0]", @intake.had_scholarships, include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part3[0].q8CashCheckPayments[0]", @intake.had_cash_check_digital_assets, include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part3[0].q10DisabilityIncome[0]", @intake.had_disability_income, include_unsure: true),

        yes_no_checkboxes("form1[0].page2[0].Part4[0].q1Alimony[0]", fetch_gated_value(@intake, :paid_alimony), include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part4[0].q1Alimony[0].IfYes[0]", @intake.has_ssn_of_alimony_recipient),

      )
      answers.merge!(
        "form1[0].page2[0].Part4[0].q2Contributions[0].IRA[0]" => yes_no_unfilled_to_checkbox(@intake.contributed_to_ira),
        "form1[0].page2[0].Part4[0].q2Contributions[0].RothIRA[0]" => yes_no_unfilled_to_checkbox(@intake.contributed_to_roth_ira),
        "form1[0].page2[0].Part4[0].q2Contributions[0]._401K[0]" => yes_no_unfilled_to_checkbox(@intake.contributed_to_401k),
        "form1[0].page2[0].Part4[0].q2Contributions[0].Other[0]" => yes_no_unfilled_to_checkbox(@intake.contributed_to_other_retirement_account),
      )

      answers.merge!(
        yes_no_checkboxes("form1[0].page2[0].Part4[0].q3PostSecondary[0]", @intake.paid_post_secondary_educational_expenses, include_unsure: true),
      )
      answers.merge!(
        keep_and_normalize({
          "form1[0].page3[0].paidFollowingExpenses[0].mortgageinterest[0]" => @intake.wants_to_itemize_yes? && @intake.ever_owned_home_yes? && @intake.paid_mortgage_interest_yes?,
          "form1[0].page3[0].paidFollowingExpenses[0].taxesStateLocal[0]" => @intake.wants_to_itemize_yes? && @intake.paid_local_tax_yes?,
          "form1[0].page3[0].paidFollowingExpenses[0].mendicalDentalPrescription[0]" => @intake.wants_to_itemize_yes? && @intake.paid_medical_expenses_yes?,
          "form1[0].page3[0].paidFollowingExpenses[0].charitableContributions[0]" => @intake.wants_to_itemize_yes? && @intake.paid_charitable_contributions_yes?,
          "form1[0].page3[0].paidExpenses[0].studentLoanInterest[0]" => @intake.paid_student_loan_interest_yes?,
          "form1[0].page3[0].paidExpenses[0].childDependentCare[0]" => @intake.had_dependents_yes? && @intake.paid_dependent_care_yes?,
          "form1[0].page3[0].paidExpenses[0].contributionsRetirementAccount[0]" => @intake.had_social_security_or_retirement_yes? && @intake.paid_retirement_contributions_yes?,
          "form1[0].page3[0].paidExpenses[0].schooldSupplies[0]" => @intake.wants_to_itemize_yes? && @intake.paid_school_supplies_yes?,
          "form1[0].page3[0].paidExpenses[0].alimonyPayments[0]" => @intake.ever_married_yes? && @intake.paid_alimony_yes?,
          "form1[0].page3[0].followingHappenDuring[0].tookEducationalClasses[0].tookEducationalClasses[0]" => @intake.paid_post_secondary_educational_expenses_yes?,
          "form1[0].page3[0].followingHappenDuring[0].sellAHome[0]" => @intake.ever_owned_home_yes? && @intake.sold_a_home_yes?,
          "form1[0].page3[0].followingHappenDuring[0].healthSavingsAccount[0]" => @intake.had_hsa_yes?,
          "form1[0].page3[0].followingHappenDuring[0].purchaseMarketplaceInsurance[0]" => @intake.bought_marketplace_health_insurance_yes?,
          "form1[0].page3[0].followingHappenDuring[0].energyEfficientItems[0].energyEfficientItems[0]" => @intake.bought_energy_efficient_items_yes?,
          "form1[0].page3[0].followingHappenDuring[0].forgaveByLender[0].forgaveByLender[0]" => @intake.had_debt_forgiven_yes?,
          "form1[0].page3[0].followingHappenDuring[0].lossRelatedDisaster[0]" => @intake.had_disaster_loss_yes?,
          "form1[0].page3[0].followingHappenDuring[0].taxCreditDisallowed[0].taxCreditDisallowed[0]" => @intake.had_tax_credit_disallowed_yes?,
          "form1[0].page3[0].followingHappenDuring[0].receivedLetterBill[0]" => @intake.received_irs_letter_yes?,
          "form1[0].page3[0].followingHappenDuring[0].estimatedTaxPayments[0].estimatedTaxPayments[0]" => @intake.made_estimated_tax_payments_yes?,
        })
      )

      answers.merge!(
        yes_no_checkboxes("form1[0].page2[0].Part4[0].q7ExpensesRelatedTo[0]", @intake.paid_self_employment_expenses, include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part5[0].q3AdoptAChild[0]", fetch_gated_value(@intake, :adopted_child), include_unsure: true),
      )
      answers.merge!(
        "form1[0].page2[0].Part5[0].q4HaveEarnedIncome[0].WhichTaxYear[0]" => @intake.tax_credit_disallowed_year
      )
      answers.merge!(
        yes_no_checkboxes("form1[0].page2[0].Part5[0].q6ReceiveTheFirst[0]", fetch_gated_value(@intake, :received_homebuyer_credit), include_unsure: true),
      )
      answers.merge!(
        "form1[0].page2[0].Part5[0].q7MakeEstimatedTax[0].HowMuch[0]" => @intake.made_estimated_tax_payments_amount,
      )
      answers.merge!(
        yes_no_checkboxes("form1[0].page2[0].Part5[0].q8FileAFederal[0]", @intake.had_capital_loss_carryover, include_unsure: true),
      )
      answers.merge!(
        # Additional Information Section
        # double check this works?
        yes_no_checkboxes("form1[0].page3[0].q1[0]", @intake.preferred_written_language.present? ? "yes" : "no"),
      )

      # TODO: This doesn't exist for spouse and it doesn't seem like we collect it anyways. It is part of the ticket though
      # answers["form1[0].page1[0].writtenCommunicationLanguage[0].whatLanguage[0]"] = @intake.preferred_written_language

      answers.merge!(
        keep_and_normalize(
          {
            "form1[0].page1[0].presidentialElectionFund[0].presidentialElectionFundYou[0]" => (@intake.presidential_campaign_fund_donation_primary? || @intake.presidential_campaign_fund_donation_primary_and_spouse?),
            "form1[0].page3[0].q2[0].spouse[0]" => (@intake.presidential_campaign_fund_donation_spouse? || @intake.presidential_campaign_fund_donation_primary_and_spouse?),
            "form1[0].page1[0].presidentialElectionFund[0].presidentialElectionFundNo[0]" => (!(@intake.presidential_campaign_fund_donation_spouse? || @intake.presidential_campaign_fund_donation_primary_and_spouse?) && !(@intake.presidential_campaign_fund_donation_primary? || @intake.presidential_campaign_fund_donation_primary_and_spouse?)),
          }
        )
      )
      answers.merge!(
        yes_no_checkboxes("form1[0].page3[0].q4[0]", @intake.balance_pay_from_bank),
      )
      answers.merge!(
        "form1[0].page3[0].q5[0].IfYesWhere[0]" => @intake.had_disaster_loss_where,
      )
      answers.merge!(
        yes_no_checkboxes("form1[0].page3[0].q7[0]", @intake.register_to_vote),
      )
      answers.merge!(demographic_info) if @intake.demographic_questions_opt_in_yes? || @intake.demographic_questions_hub_edit
      answers.merge!(
        "form1[0].page3[0].AdditionalComments[0].AdditionalComments[1]" => additional_comments,
      )
      answers.merge!(vita_consent_to_disclose_info) if @intake.client&.consent&.disclose_consented_at
      answers
    end

    def vita_consent_to_disclose_info
      # aka form 15080 on page 4 info
      return {} unless @intake.primary_consented_to_service_at.present?

      data = {
        "form1[0].page4[0].primaryTaxpayer[0]" => @intake.primary.first_and_last_name,
        "form1[0].page4[0].primarydateSigned[0]" => strftime_date(@intake.primary_consented_to_service_at),
      }
      if @intake.spouse_consented_to_service_at.present?
        data.merge!(
          "form1[0].page4[0].secondaryTaxpayer[0]" => @intake.spouse.first_and_last_name,
          "form1[0].page4[0].secondaryDateSigned[0]" => strftime_date(@intake.spouse_consented_to_service_at),
          )
      end
      data
    end

    def you_and_spouse_info
      hash = {
        # You
        "form1[0].page1[0].yourFirstName[0]" => @intake.primary.first_name,
        "form1[0].page1[0].yourMiddleInitial[0]" => @intake.primary.middle_initial,
        "form1[0].page1[0].yourLastName[0]" => @intake.primary.last_name,
        "form1[0].page1[0].mailingAddress[0]" => @intake.street_address,
        "form1[0].page1[0].yourDateOfBirth[0]" => strftime_date(@intake.primary.birth_date),
        "form1[0].page1[0].yourEmailAddress[0]" => @intake.email_address,
        "form1[0].page1[0].yourJobTitle[0]" => @intake.primary_job_title,
        "form1[0].page1[0].yourTelephoneNumber[0]" => @intake.formatted_phone_number,

        # Spouse
        "form1[0].page1[0].spousesFirstName[0]" => @intake.spouse.first_name,
        "form1[0].page1[0].spousesMiddleInitial[0]" => @intake.spouse.middle_initial,
        "form1[0].page1[0].spousesLastName[0]" => @intake.spouse.last_name,
        "form1[0].page1[0].spousesDateOfBirth[0]" => strftime_date(@intake.spouse.birth_date),
        "form1[0].page1[0].spousesJobTitle[0]" => @intake.spouse_job_title,
        "form1[0].page1[0].spousesTelephoneNumber[0]" => @intake.formatted_spouse_phone_number,
      }.merge(
        # These represent "You", "Spouse", "No" on the PDF. Pass a boolean as to whether it should be checked.
        keep_and_normalize(
          {
            # You
            "form1[0].page1[0].youSpouseWereIn[0].column1[0].usCitizen[0].usCitizenYou[0]" => @intake.primary_us_citizen_yes?,
            "form1[0].page1[0].youSpouseWereIn[0].column1[0].fullTimeStudent[0].studentYou[0]" => @intake.was_full_time_student_yes?,
            "form1[0].page1[0].youSpouseWereIn[0].column2[0].legallyBlind[0].legallyBlindYou[0]" => @intake.was_blind_yes?,
            "form1[0].page1[0].youSpouseWereIn[0].column2[0].totallyPermanentlyDisabled[0].disabledYou[0]" => @intake.had_disability_yes?,
            "form1[0].page1[0].youSpouseWereIn[0].column1[0].usOnVisa[0].onVisaYou[0]" => @intake.primary_visa_yes?,
            "form1[0].page1[0].youSpouseWereIn[0].column2[0].issuedIdentityProtection[0].identityProtectionYou[0]" => @intake.issued_identity_pin_yes?,
             "form1[0].page1[0].liveWorkStates[0].liveWorkYes[0]" => @intake.multiple_states_yes?,

            # Spouse
            "form1[0].page1[0].youSpouseWereIn[0].column1[0].usCitizen[0].usCitizenSpouse[0]" => @intake.spouse_us_citizen_yes?,
            "form1[0].page1[0].youSpouseWereIn[0].column1[0].fullTimeStudent[0].studentSpouse[0]" => @intake.spouse_was_full_time_student_yes?,
            "form1[0].page1[0].youSpouseWereIn[0].column2[0].legallyBlind[0].legallyBlindSpouse[0]" => @intake.spouse_was_blind_yes?,
            "form1[0].page1[0].youSpouseWereIn[0].column2[0].totallyPermanentlyDisabled[0].disabledSpouse[0]" => @intake.spouse_had_disability_yes?,
            "form1[0].page1[0].youSpouseWereIn[0].column1[0].usOnVisa[0].onVisaSpouse[0]" => @intake.spouse_visa_yes?,
            "form1[0].page1[0].youSpouseWereIn[0].column2[0].issuedIdentityProtection[0].identityProtectionSpouse[0]" => @intake.spouse_issued_identity_pin_yes?,

            # Negative
            "form1[0].page1[0].youSpouseWereIn[0].column1[0].usCitizen[0].usCitizenNo[0]" => @intake.primary_us_citizen_no? && !@intake.spouse_us_citizen_yes?,
            "form1[0].page1[0].youSpouseWereIn[0].column1[0].fullTimeStudent[0].studentNo[0]" => @intake.was_full_time_student_no? && !@intake.spouse_was_full_time_student_yes?,
            "form1[0].page1[0].youSpouseWereIn[0].column2[0].legallyBlind[0].legallyBlindNo[0]" => @intake.was_blind_no? && !@intake.spouse_was_blind_yes?,
            "form1[0].page1[0].youSpouseWereIn[0].column2[0].totallyPermanentlyDisabled[0].disabledNo[0]" => @intake.had_disability_no? && !@intake.spouse_had_disability_yes?,
            "form1[0].page1[0].youSpouseWereIn[0].column1[0].usOnVisa[0].onVisaNo[0]" => @intake.primary_visa_no? && @intake.spouse_visa_no?,
            "form1[0].page1[0].youSpouseWereIn[0].column2[0].issuedIdentityProtection[0].identityProtectionNo[0]" => (!@intake.issued_identity_pin_yes? && !@intake.spouse_issued_identity_pin_yes?),
            "form1[0].page1[0].liveWorkStates[0].liveWorkNo[0]" => @intake.multiple_states_no?,

            # People who have digital assets are considered out of scope
            "form1[0].page1[0].youSpouseWereIn[0].column2[0].holdDigitalAssets[0].digitalAssetsNo[0]" => true,

            # Refund section
            "form1[0].page1[0].dueARefund[0].refundOther[0]" => @intake.savings_purchase_bond_yes?,
            "form1[0].page1[0].dueARefund[0].refundDirectDeposit[0]" => @intake.refund_payment_method_direct_deposit?,
            "form1[0].page1[0].dueARefund[0].refundCheckMail[0]" => @intake.refund_payment_method_check?,
            "form1[0].page1[0].dueARefund[0].refundSplitAccounts[0]" => @intake.savings_split_refund_yes?,

            "form1[0].page1[0].haveBlanceDue[0].blanceBankAccount[0]" => @intake.balance_pay_from_bank_yes?,
            "form1[0].page1[0].haveBlanceDue[0].blanceMailPayment[0]" => @intake.balance_pay_from_bank_no?,
          }
        )
      )

      # TODO: How do we handle alternate languages?

      if @intake.savings_purchase_bond_yes?
        hash["form1[0].page1[0].dueARefund[0].refundOtherExplain[0]"] = "Purchase United States Savings Bond"
      end

      hash
    end

    def yes_no_checkboxes(pdf_key_base, enum_value, include_unsure: false, option_prefix: true)
      yes_key = option_prefix ? "optionYes" : "yes"

      result = {
        "#{pdf_key_base}.#{yes_key}[0]" => enum_value == "yes" ? "1" : "Off",
        "#{pdf_key_base}.optionNo[0]" => enum_value == "no" ? "1" : "Off",
      }
      if include_unsure
        result["#{pdf_key_base}.optionUnsure[0]"] = enum_value == "unsure" ? "1" : "Off"
      end
      result
    end

    # Trims the hash to only the values as tested by the block, which should
    # return true if keeping. Additionally, it normalizes the value to the
    # value specified.
    # 
    # @see {Enumerable#keep_if}
    # @see {Hash#transform_values}
    #
    # @param normalize_to [Proc, Any] Either a literal value to normalize to or a callable to call on the value to normalize. Defaults to "1"
    # @param keep_if [Proc] Passed literaly to Hash#keep_if. Defaults to a truthiness check on value
    # @return [Hash]
    def keep_and_normalize(pdf_hash, normalize_to: "1", keep_if: ->(_k, v) { v })
      normalizer = if normalize_to.respond_to?(:call)
                     normalize_to
                   else
                     proc { normalize_to }
                   end

      pdf_hash.keep_if(&keep_if).transform_values(&normalizer)
    end

    def fetch_gated_value(intake, field)
      gating_question_columns = GATES.select do |_gating_question, gated_values|
        gated_values.any?(field)
      end.map(&:first)

      gating_question_values = gating_question_columns.map { |c| intake.send(c) }
      gated_question_value = intake.send(field)
      if gating_question_values.any?("no") && gated_question_value == "unfilled"
        "no"
      else
        gated_question_value
      end
    end

    def spouse_info
      {
        "form1[0].page1[0].spousesFirstName[0]" => @intake.spouse.first_name,
        "form1[0].page1[0].spousesMiddleInitial[0]" => @intake.spouse.middle_initial,
        "form1[0].page1[0].spousesLastName[0]" => @intake.spouse.last_name,
        "form1[0].page1[0].spousesTelephoneNumber[0]" => @intake.spouse_phone_number,
        "form1[0].page1[0].spousesDateOfBirth[0]" => strftime_date(@intake.spouse.birth_date),
        "form1[0].page1[0].spousesJobTitle[0]" => @intake.spouse_job_title,
      }.merge(
        keep_and_normalize(
          {
            "form1[0].page1[0].youSpouseWereIn[0].column1[0].usCitizen[0].usCitizenSpouse[0]" => @intake.spouse_us_citizen_yes?,
            "form1[0].page1[0].youSpouseWereIn[0].column1[0].fullTimeStudent[0].studentSpouse[0]" => @intake.spouse_was_full_time_student_yes?,
            "form1[0].page1[0].youSpouseWereIn[0].column2[0].totallyPermanentlyDisabled[0].disabledSpouse[0]" => @intake.spouse_had_disability_yes?,
            "form1[0].page1[0].youSpouseWereIn[0].column2[0].legallyBlind[0].legallyBlindSpouse[0]" => @intake.spouse_was_blind_yes?,
          }
        )
      )
    end

    def dependents_info
      answers = {}
      @dependents.first(3).each_with_index do |dependent, index|
        single_dependent_params(dependent, index: index + 1).each do |key, value|
          answers[key] = value
        end
      end
      answers
    end

    def demographic_info
      {
        "form1[0].page3[0].q8[0].veryWell[0]" => @intake.demographic_english_conversation_very_well? ? '1' : nil,
        "form1[0].page3[0].q8[0].well[0]" => @intake.demographic_english_conversation_well? ? '1' : nil,
        "form1[0].page3[0].q8[0].notWell[0]" => @intake.demographic_english_conversation_not_well? ? '1' : nil,
        "form1[0].page3[0].q8[0].notAtAll[0]" => @intake.demographic_english_conversation_not_at_all? ? '1' : nil,
        "form1[0].page3[0].q8[0].notAnswer[0]" => @intake.demographic_english_conversation_prefer_not_to_answer? ? '1' : nil,

        "form1[0].page3[0].q9[0].veryWell[0]" => @intake.demographic_english_reading_very_well? ? '1' : nil,
        "form1[0].page3[0].q9[0].well[0]" => @intake.demographic_english_reading_well? ? '1' : nil,
        "form1[0].page3[0].q9[0].notWell[0]" => @intake.demographic_english_reading_not_well? ? '1' : nil,
        "form1[0].page3[0].q9[0].notAtAll[0]" => @intake.demographic_english_reading_not_at_all? ? '1' : nil,
        "form1[0].page3[0].q9[0].notAnswer[0]" => @intake.demographic_english_reading_prefer_not_to_answer? ? '1' : nil,

        "form1[0].page3[0].q10[0].optionYes[0]" => @intake.demographic_disability_yes? ? '1' : nil,
        "form1[0].page3[0].q10[0].optionNo[0]" => @intake.demographic_disability_no? ? '1' : nil,
        "form1[0].page3[0].q10[0].notAnswer[0]" => @intake.demographic_disability_prefer_not_to_answer? ? '1' : nil,

        "form1[0].page3[0].q11[0].optionYes[0]" => @intake.demographic_veteran_yes? ? '1' : nil,
        "form1[0].page3[0].q11[0].optionNo[0]" => @intake.demographic_veteran_no? ? '1' : nil,
        "form1[0].page3[0].q11[0].notAnswer[0]" => @intake.demographic_veteran_prefer_not_to_answer? ? '1' : nil,

        "form1[0].page3[0].q12[0].americanIndian[0]" => bool_checkbox(@intake.demographic_primary_american_indian_alaska_native),
        "form1[0].page3[0].q12[0].asian[0]" => bool_checkbox(@intake.demographic_primary_asian),
        "form1[0].page3[0].q12[0].blackAfrican[0]" => bool_checkbox(@intake.demographic_primary_black_african_american),
        "form1[0].page3[0].q12[0].nativeHawaiian[0]" => bool_checkbox(@intake.demographic_primary_native_hawaiian_pacific_islander),
        "form1[0].page3[0].q12[0].white[0]" => bool_checkbox(@intake.demographic_primary_white),
        "form1[0].page3[0].q12[0].notAnswer[0]" => bool_checkbox(@intake.demographic_primary_prefer_not_to_answer_race),

        "form1[0].page3[0].q13[0].americanIndian[0]" => bool_checkbox(@intake.demographic_spouse_american_indian_alaska_native),
        "form1[0].page3[0].q13[0].asian[0]" => bool_checkbox(@intake.demographic_spouse_asian),
        "form1[0].page3[0].q13[0].blackAfrican[0]" => bool_checkbox(@intake.demographic_spouse_black_african_american),
        "form1[0].page3[0].q13[0].nativeHawaiian[0]" => bool_checkbox(@intake.demographic_spouse_native_hawaiian_pacific_islander),
        "form1[0].page3[0].q13[0].white[0]" => bool_checkbox(@intake.demographic_spouse_white),
        "form1[0].page3[0].q13[0].notAnswer[0]" => bool_checkbox(@intake.demographic_spouse_prefer_not_to_answer_race),
        "form1[0].page3[0].q13[0].noSpouse[0]" => nil,

        "form1[0].page3[0].q14[0].hispanicLatino[0]" => bool_checkbox(@intake.demographic_primary_ethnicity_hispanic_latino?),
        "form1[0].page3[0].q14[0].notHispanicLatino[0]" => bool_checkbox(@intake.demographic_primary_ethnicity_not_hispanic_latino?),
        "form1[0].page3[0].q14[0].notAnswer[0]" => bool_checkbox(@intake.demographic_primary_ethnicity_prefer_not_to_answer?),

        "form1[0].page3[0].q15[0].hispanicLatino[0]" => bool_checkbox(@intake.demographic_spouse_ethnicity_hispanic_latino?),
        "form1[0].page3[0].q15[0].notHispanicLatino[0]" => bool_checkbox(@intake.demographic_spouse_ethnicity_not_hispanic_latino?),
        "form1[0].page3[0].q15[0].notAnswer[0]" => bool_checkbox(@intake.demographic_spouse_ethnicity_prefer_not_to_answer?),
        "form1[0].page3[0].q15[0].noSpouse[0]" => nil,
      }
    end

    private

    def single_dependent_params(dependent, index:)
      {
        "form1[0].page1[0].namesOf[0].Row#{index}[0].name[0]" => dependent.full_name,
        "form1[0].page1[0].namesOf[0].Row#{index}[0].dateBirth[0]" => strftime_date(dependent.birth_date),
        "form1[0].page1[0].namesOf[0].Row#{index}[0].relationship[0]" => dependent.relationship,
        "form1[0].page1[0].namesOf[0].Row#{index}[0].months[0]" => dependent.months_in_home.to_s,
        "form1[0].page1[0].namesOf[0].Row#{index}[0].USCitizen[0]" => yes_no_unfilled_to_YN(dependent.us_citizen),
        "form1[0].page1[0].namesOf[0].Row#{index}[0].residentOf[0]" => yes_no_unfilled_to_YN(dependent.north_american_resident),
        "form1[0].page1[0].namesOf[0].Row#{index}[0].singleMarried[0]" => married_to_SM(dependent.was_married),
        "form1[0].page1[0].namesOf[0].Row#{index}[0].student[0]" => yes_no_unfilled_to_YN(dependent.was_student),
        "form1[0].page1[0].namesOf[0].Row#{index}[0].disabled[0]" => yes_no_unfilled_to_YN(dependent.disabled),
        "form1[0].page1[0].namesOf[0].Row#{index}[0].claimedBySomeone[0]" => yes_no_unfilled_to_YN(dependent.can_be_claimed_by_other),
        "form1[0].page1[0].namesOf[0].Row#{index}[0].providedMoreThen[0]" => yes_no_unfilled_to_YN(dependent.provided_over_half_own_support),
        "form1[0].page1[0].namesOf[0].Row#{index}[0].hadIncomeLess[0]" => yes_no_unfilled_to_YN(dependent.below_qualifying_relative_income_requirement),
        "form1[0].page1[0].namesOf[0].Row#{index}[0].supportPerson[0]" => yes_no_unfilled_to_YN(dependent.filer_provided_over_half_support),
        "form1[0].page1[0].namesOf[0].Row#{index}[0].maintainedHome[0]" => yes_no_unfilled_to_YN(dependent.filer_provided_over_half_housing_support),
      }
    end

    def additional_comments
      parts = []

      parts << "#{@intake.additional_info} #{@intake.final_info}" if @intake.additional_info.present? || @intake.final_info.present?

      parts << "Other income types: #{@intake.other_income_types}" if @intake.other_income_types.present?

      parts << <<~COMMENT.strip if @dependents.length > 3
        Additional Dependents:
        #{
        @dependents[3..].map do |dependent|
          letters = ('a'..'i').to_a
          dependent_values = single_dependent_params(dependent, index: 0).values
          cvp_values = []
          tagged_values = []
          dependent_values.each do |val|
            letter = letters.shift
            if letter
              tagged_values << "(#{letter}) #{val}"
            else
              cvp_values << val
            end
          end.compact
          "#{tagged_values.join(' ')} CVP: #{cvp_values.join('/')}"
        end.join("\n")
        }
      COMMENT
      parts.join("\n")
    end

    def determine_direct_deposit(intake)
      return "yes" if intake.refund_payment_method_direct_deposit?
      return "no" if intake.refund_payment_method_check?

      "unfilled"
    end

    def yes_no_unfilled_to_YN(yes_no_unfilled)
      {
        "yes" => "Y",
        "no" => "N",
        "unfilled" => ""
      }[yes_no_unfilled]
    end

    def married_to_SM(was_married_yes_no_unfilled)
      {
        "yes" => "M",
        "no" => "S",
        "unfilled" => ""
      }[was_married_yes_no_unfilled]
    end
  end
end
