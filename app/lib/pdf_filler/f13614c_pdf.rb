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

      answers.merge!({
        "form1[0].page1[0].writtenCommunicationLanguage[0].otherLanguageNo[0]" => @intake.written_language_preference_english? ? '1' : nil,
        "form1[0].page1[0].writtenCommunicationLanguage[0].otherLanguageYou[0]" => @intake.written_language_preference_english? ? nil : '1',
        "form1[0].page1[0].writtenCommunicationLanguage[0].whatLanguage[0]" => @intake.written_language_preference_english? ? nil : @intake.preferred_written_language_string
      })

      answers.merge!(
        keep_and_normalize(
          with_prefix("form1[0].page1[0].maritalStatus[0]") do
            {
              "statusNeverMarried[0]" => @intake.ever_married_no?,
              "statusMarried[0]" => @intake.married_yes?,
              # Yes, this is how it is in the pdf.
              "statusLegallySeparated[0].statusLegallySeparated[0]" => @intake.separated_yes?,
              "statusDivorced[0].statusDivorced[0]" => @intake.divorced_yes?,
              "statusWidowed[0].statusWidowed[0]" => @intake.widowed_yes?,
              "liveWithSpouse[0].liveWithYes[0]" => @intake.lived_with_spouse_yes?,
              "liveWithSpouse[0].liveWithNo[0]" => @intake.lived_with_spouse_no?,
              "marriedForAll[0].forAllYes[0]" => @intake.married_for_all_of_tax_year_yes?,
              "marriedForAll[0].forAllNo[0]" => @intake.married_for_all_of_tax_year_no?,
            }
          end
        )
      )

      answers["form1[0].page1[0].maritalStatus[0].statusLegallySeparated[0].dateSeparateDecree[0]"] = @intake.separated_year
      answers["form1[0].page1[0].maritalStatus[0].statusDivorced[0].dateFinalDecree[0]"] = @intake.divorced_year
      answers["form1[0].page1[0].maritalStatus[0].statusWidowed[0].yearSpousesDeath[0]"] = @intake.widowed_year

      answers["form1[0].page1[0].anyoneElseClaim[0].otherClaimYes[0]"] = yes_no_unfilled_to_checkbox(@intake.claimed_by_another)
      answers["form1[0].page1[0].anyoneElseClaim[0].otherClaimNo[0]"] = yes_no_unfilled_to_opposite_checkbox(@intake.claimed_by_another)

      answers["form1[0].page1[0].howToVote[0].voteInformationYes[0]"] = yes_no_unfilled_to_checkbox(@intake.register_to_vote)
      answers["form1[0].page1[0].howToVote[0].voteInformationNo[0]"] = yes_no_unfilled_to_opposite_checkbox(@intake.register_to_vote)

      # PAGE 2
      answers.merge!(
        keep_and_normalize(
          with_prefix("form1[0].page2[0].receivedMoneyFrom[0]") do
            {
              "wagesPartFull[0]" => @intake.had_wages_yes?,
              "receivedMoneyTimps[0]" => @intake.had_tips_yes?,
              "retirementAccount[0]" => @intake.had_retirement_income_yes?,
              "disabilityBenefits[0].disabilityBenefits[0]" => @intake.had_disability_income_yes?,
              "socialSecurityRailroad[0]" => @intake.had_social_security_income_yes?,
              "unemploymentBenefits[0]" => @intake.had_unemployment_income_yes?,
              "refundStateLocal[0]" => @intake.had_local_tax_refund_yes?,
              "interestOrDividends[0]" => @intake.had_interest_income_yes?,
              "saleStocksBonds[0]" => @intake.had_asset_sale_income_yes?,
              "reportALoss[0].reportLossYes[0]" => @intake.reported_asset_sale_loss_yes?,
              "reportALoss[0].reportLossNo[0]" => @intake.reported_asset_sale_loss_no?,
              "receivedAlimony[0]" => @intake.received_alimony_yes?,
              "incomeRentingHouse[0].incomeRentingHouse[0]" => @intake.had_rental_income_yes?,
              "useAsPersonal[0].personalResidenceYes[0]" => @intake.had_rental_income_and_used_dwelling_as_residence_yes?,
              "useAsPersonal[0].personalResidenceNo[0]" => @intake.had_rental_income_and_used_dwelling_as_residence_no?,
              "incomeRentingVehicle[0]" => @intake.had_rental_income_from_personal_property_yes?,
              "gamblingLotteryWinnings[0]" => @intake.had_gambling_income_yes?,
              "paymentsContractSelf[0]" => @intake.had_self_employment_income_yes?,
              "lossLastReturn[0].reportLossYes[0]" => @intake.reported_self_employment_loss_yes?,
              "lossLastReturn[0].reportLossNo[0]" => @intake.reported_self_employment_loss_no?,
              "otherMoneyReceived[0].otherMoneyReceived[0]" => @intake.had_other_income_yes?
            }
          end
        )
      )

      answers["form1[0].page2[0].receivedMoneyFrom[0].howManyJobs[0]"] = @intake.job_count.to_s

      # PAGE TWO: right-side certified volunteer section
      answers.merge!(
        # Wages: W-2s
        "form1[0].page2[0].incomeIncluded[0].formW2s[0]" => yes_no_unfilled_to_checkbox(@intake.cv_w2s_cb),
        "form1[0].page2[0].incomeIncluded[0].formW2sNumber[0]" => @intake.cv_w2s_count.to_s,

        # Tips
        "form1[0].page2[0].incomeIncluded[0].tipsBasicReported[0]" => yes_no_unfilled_to_checkbox(@intake.cv_had_tips_cb),

        # Retirement income: 1099-R, Qualified Charitable Distribution
        "form1[0].page2[0].incomeIncluded[0].form1099R[0]" => yes_no_unfilled_to_checkbox(@intake.cv_1099r_cb),
        "form1[0].page2[0].incomeIncluded[0].form1099RNumber[0]" => @intake.cv_1099r_count,
        "form1[0].page2[0].incomeIncluded[0].qualifiedCharitableDistribution[0]" => yes_no_unfilled_to_checkbox(@intake.cv_1099r_charitable_dist_cb),
        "form1[0].page2[0].incomeIncluded[0].qualifiedCharitableAmount[0]" => @intake.cv_1099r_charitable_dist_amt,

        # Disability
        "form1[0].page2[0].incomeIncluded[0].disabilityBenefits[0]" => yes_no_unfilled_to_checkbox(@intake.cv_disability_benefits_1099r_or_w2_cb),
        "form1[0].page2[0].incomeIncluded[0].disabilityBenefitsNumber[0]" => @intake.cv_disability_benefits_1099r_or_w2_count,

        # SSA-1099, RRB-1099
        "form1[0].page2[0].incomeIncluded[0].ssaRRB1099[0]" => yes_no_unfilled_to_checkbox(@intake.cv_ssa1099_rrb1099_cb),
        "form1[0].page2[0].incomeIncluded[0].ssaRRB1099Number[0]" => @intake.cv_ssa1099_rrb1099_count,

        # Unemployment 1099-G
        "form1[0].page2[0].incomeIncluded[0].form1099G[0]" => yes_no_unfilled_to_checkbox(@intake.cv_1099g_cb),
        "form1[0].page2[0].incomeIncluded[0].form1099GNumber[0]" => @intake.cv_1099g_count,

        # Refund
        "form1[0].page2[0].incomeIncluded[0].refund[0].refund[0]" => yes_no_unfilled_to_checkbox(@intake.cv_local_tax_refund_cb),
        "form1[0].page2[0].incomeIncluded[0].refund[0].refundAmount[0]" => @intake.cv_local_tax_refund_amt,

        # Itemized last year
        "form1[0].page2[0].incomeIncluded[0].itemizedLastYear[0].itemizedLastYear[0]" => yes_no_unfilled_to_checkbox(@intake.cv_itemized_last_year_cb),
        "form1[0].page2[0].incomeIncluded[0].itemizedLastYear[0].itemizedYes[0]" => yes_no_unfilled_to_checkbox(@intake.cv_itemized_last_year_cb),
        "form1[0].page2[0].incomeIncluded[0].itemizedLastYear[0].itemizedNo[0]" => yes_no_unfilled_to_opposite_checkbox(@intake.cv_itemized_last_year_cb),

        # 1099-INT/DIV
        "form1[0].page2[0].incomeIncluded[0].form1099INTDIV[0].form1099INT[0]" => yes_no_unfilled_to_checkbox(@intake.cv_1099int_cb),
        "form1[0].page2[0].incomeIncluded[0].form1099INTDIV[0].form1099INTNumber[0]" => @intake.cv_1099int_count,
        "form1[0].page2[0].incomeIncluded[0].form1099INTDIV[0].form1099DIV[0]" => yes_no_unfilled_to_checkbox(@intake.cv_1099div_cb),
        "form1[0].page2[0].incomeIncluded[0].form1099INTDIV[0].form1099DIVNumber[0]" => @intake.cv_1099div_count,

        # 1099-B
        "form1[0].page2[0].incomeIncluded[0].form1099B[0].form1099B[0]" => yes_no_unfilled_to_checkbox(@intake.cv_1099b_cb),
        "form1[0].page2[0].incomeIncluded[0].form1099B[0].form1099BNumber[0]" => @intake.cv_1099b_count,

        # Capital loss carryover
        "form1[0].page2[0].incomeIncluded[0].form1099B[0].capitalLossCarryover[0].capitalLossCarryover[0]" => yes_no_unfilled_to_checkbox(@intake.cv_capital_loss_carryover_cb),
        "form1[0].page2[0].incomeIncluded[0].form1099B[0].capitalLossCarryover[0].capitalLossCarryoverYes[0]" => yes_no_unfilled_to_checkbox(@intake.cv_capital_loss_carryover_cb),
        "form1[0].page2[0].incomeIncluded[0].form1099B[0].capitalLossCarryover[0].capitalLossCarryoverNo[0]" => yes_no_unfilled_to_opposite_checkbox(@intake.cv_capital_loss_carryover_cb),

        # Alimony
        "form1[0].page2[0].incomeIncluded[0].alimonyIncome[0].alimonyIncome[0]" => yes_no_unfilled_to_checkbox(@intake.cv_alimony_income_cb),
        "form1[0].page2[0].incomeIncluded[0].alimonyIncome[0].alimonyAmount[0]" => @intake.cv_alimony_income_amt,
        # Alimony - Excluded from income
        "form1[0].page2[0].incomeIncluded[0].alimonyIncome[0].excludedYes[0]" => yes_no_unfilled_to_checkbox(@intake.cv_alimony_excluded_from_income_cb),
        "form1[0].page2[0].incomeIncluded[0].alimonyIncome[0].excludedNo[0]" => yes_no_unfilled_to_opposite_checkbox(@intake.cv_alimony_excluded_from_income_cb),

        # Rental income
        "form1[0].page2[0].incomeIncluded[0].rentalIncome[0].rentalIncome[0]" => yes_no_unfilled_to_checkbox(@intake.cv_rental_income_cb),
        "form1[0].page2[0].incomeIncluded[0].rentalIncome[0].rentalExpense[0]" => yes_no_unfilled_to_checkbox(@intake.cv_rental_expense_cb),
        "form1[0].page2[0].incomeIncluded[0].rentalIncome[0].rentalExpenseAmount[0]" => @intake.cv_rental_expense_amt,

        # Gambling
        "form1[0].page2[0].incomeIncluded[0].formW2G[0].formW2G[0]" => yes_no_unfilled_to_checkbox(@intake.cv_w2g_or_other_gambling_winnings_cb),
        "form1[0].page2[0].incomeIncluded[0].formW2G[0].formW2GNumber[0]" => @intake.cv_w2g_or_other_gambling_winnings_count,

        # Schedule C: Self-employment
        "form1[0].page2[0].incomeIncluded[0].scheduleC[0]" => yes_no_unfilled_to_checkbox(@intake.cv_schedule_c_cb),

        "form1[0].page2[0].incomeIncluded[0].form1099MISC[0]" => yes_no_unfilled_to_checkbox(@intake.cv_1099misc_cb),
        "form1[0].page2[0].incomeIncluded[0].form1099MISCNumber[0]" => @intake.cv_1099misc_count,

        "form1[0].page2[0].incomeIncluded[0].form1099NEC[0]" => yes_no_unfilled_to_checkbox(@intake.cv_1099nec_cb),
        "form1[0].page2[0].incomeIncluded[0].form1099NECNumber[0]" => @intake.cv_1099nec_count,

        "form1[0].page2[0].incomeIncluded[0].form1099K[0]" => yes_no_unfilled_to_checkbox(@intake.cv_1099k_cb),
        "form1[0].page2[0].incomeIncluded[0].form1099KNumber[0]" => @intake.cv_1099k_count,

        "form1[0].page2[0].incomeIncluded[0].otherInomceReported[0]" => yes_no_unfilled_to_checkbox(@intake.cv_other_income_reported_elsewhere_cb),

        "form1[0].page2[0].incomeIncluded[0].scheduleCExpenses[0]" => yes_no_unfilled_to_checkbox(@intake.cv_schedule_c_expenses_cb),
        "form1[0].page2[0].incomeIncluded[0].scheduleCExpensesAmount[0]" => @intake.cv_schedule_c_expenses_amt,

        # Other income
        "form1[0].page2[0].incomeIncluded[0].otherIncome[0].otherIncome[0]" => yes_no_unfilled_to_checkbox(@intake.cv_other_income_cb),

        # Notes/Comments
        "form1[0].page2[0].IncomeIncludedComment[0].IncomeIncludedComments[0]" => @intake.cv_p2_notes_comments,
      )

      # PAGE 3
      answers.merge!(
        keep_and_normalize({
          # page 3 lhs section 1 of 3
          "form1[0].page3[0].paidFollowingExpenses[0].mortgageinterest[0]" => @intake.paid_mortgage_interest_yes?,
          "form1[0].page3[0].paidFollowingExpenses[0].taxesStateLocal[0]" => @intake.paid_local_tax_yes?,
          "form1[0].page3[0].paidFollowingExpenses[0].mendicalDentalPrescription[0]" => @intake.paid_medical_expenses_yes?,
          "form1[0].page3[0].paidFollowingExpenses[0].charitableContributions[0]" => @intake.paid_charitable_contributions_yes?,

          # page 3 lhs section 2 of 3
          "form1[0].page3[0].paidExpenses[0].studentLoanInterest[0]" => @intake.paid_student_loan_interest_yes?,
          "form1[0].page3[0].paidExpenses[0].childDependentCare[0]" => @intake.paid_dependent_care_yes?,
          "form1[0].page3[0].paidExpenses[0].contributionsRetirementAccount[0]" => @intake.paid_retirement_contributions_yes?,
          "form1[0].page3[0].paidExpenses[0].schooldSupplies[0]" => @intake.paid_school_supplies_yes?,
          "form1[0].page3[0].paidExpenses[0].alimonyPayments[0]" => @intake.paid_alimony_yes?,

          # page 3 lhs section 3 of 3
          "form1[0].page3[0].followingHappenDuring[0].tookEducationalClasses[0].tookEducationalClasses[0]" => @intake.paid_post_secondary_educational_expenses_yes?,
          "form1[0].page3[0].followingHappenDuring[0].sellAHome[0]" => @intake.sold_a_home_yes?,
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
          # page 3 rhs section 1 of 3
          'form1[0].page3[0].stndardItemizedDeductions[0].form1098[0]' => bool_checkbox(@intake.cv_1098_cb_yes?),
          'form1[0].page3[0].stndardItemizedDeductions[0].form1098Number[0]' => @intake.cv_1098_count.to_s,
          'form1[0].page3[0].stndardItemizedDeductions[0].standardDeduction[0]' => bool_checkbox(@intake.cv_med_expense_standard_deduction_cb_yes?),
          'form1[0].page3[0].stndardItemizedDeductions[0].itemizedDeduction[0]' => bool_checkbox(@intake.cv_med_expense_itemized_deduction_cb_yes?),
          'form1[0].page3[0].stndardItemizedComments[0].stndardItemizedComments[0]' => @intake.cv_14c_page_3_notes_part_1,

          # page 3 rhs section 2 of 3
          'form1[0].page3[0].expensesToReport[0].form1098E[0]' => bool_checkbox(@intake.cv_1098e_cb_yes?),
          'form1[0].page3[0].expensesToReport[0].childDependentCare[0]' => bool_checkbox(@intake.cv_child_dependent_care_credit_cb_yes?),
          'form1[0].page3[0].expensesToReport[0].iraBasicRoth[0]' => bool_checkbox(@intake. contributed_to_ira_yes?),
          'form1[0].page3[0].expensesToReport[0].educatorExpensesDeduction[0]' => bool_checkbox(@intake.cv_edu_expenses_deduction_cb_yes?),
          'form1[0].page3[0].expensesToReport[0].educatorExpensesDeductionAmount[0]' => @intake.cv_edu_expenses_deduction_amt.to_s,
          'form1[0].page3[0].expensesToReport[0].alimonyPayments[0].alimonyPayments[0]' => bool_checkbox(@intake.cv_paid_alimony_w_spouse_ssn_cb_yes?),
          'form1[0].page3[0].expensesToReport[0].alimonyPayments[0].alimonyPaymentsAmount[0]' => @intake.cv_paid_alimony_w_spouse_ssn_amt.to_s,
          'form1[0].page3[0].expensesToReport[0].alimonyPayments[0].adjustementYes[0]' => yes_no_unfilled_to_checkbox(@intake.cv_alimony_income_adjustment_yn_cb),
          'form1[0].page3[0].expensesToReport[0].alimonyPayments[0].adjustementNo[0]' => yes_no_unfilled_to_opposite_checkbox(@intake.cv_alimony_income_adjustment_yn_cb),
          'form1[0].page3[0].expensesReportComments[0].expensesReportComments[0]' => @intake.cv_14c_page_3_notes_part_2,

          # page 3 rhs section 3 of 3
          'form1[0].page3[0].informationToReport[0].taxableScholarshipIncome[0]' => bool_checkbox(@intake.cv_taxable_scholarship_income_cb_yes?),
          'form1[0].page3[0].informationToReport[0].form1098T[0]' => bool_checkbox(@intake.cv_1098t_cb_yes?),
          'form1[0].page3[0].informationToReport[0].educationCreditTuition[0]' => bool_checkbox(@intake.cv_edu_credit_or_tuition_deduction_cb_yes?),
          'form1[0].page3[0].informationToReport[0].saleOfHome[0]' => bool_checkbox(@intake.cv_1099s_cb_yes?),
          'form1[0].page3[0].informationToReport[0].hsaContributions[0]' => bool_checkbox(@intake.cv_hsa_contrib_cb_yes?),
          'form1[0].page3[0].informationToReport[0].hsaDistributions[0]' => bool_checkbox(@intake.cv_hsa_distrib_cb_yes?),
          'form1[0].page3[0].informationToReport[0].form1095A[0]' => bool_checkbox(@intake.cv_1095a_cb_yes?),
          'form1[0].page3[0].informationToReport[0].efficientHomeImprovement[0]' => bool_checkbox(@intake.cv_energy_efficient_home_improv_credit_cb_yes?),
          'form1[0].page3[0].informationToReport[0].form1099C[0]' => bool_checkbox(@intake.cv_1099c_cb_yes?),
          'form1[0].page3[0].informationToReport[0].form1099A[0]' => bool_checkbox(@intake.cv_1099a_cb_yes?),
          'form1[0].page3[0].informationToReport[0].disasterReliefImpacts[0]' => bool_checkbox(@intake.cv_disaster_relief_impacts_return_cb_yes?),
          'form1[0].page3[0].informationToReport[0].disallowedPreviousYear[0]' => bool_checkbox(@intake.cv_eitc_ctc_aotc_hoh_disallowed_in_a_prev_yr_cb_yes?),
          'form1[0].page3[0].informationToReport[0].YearDisallowedReason[0].yearDisallowed[0]' => @intake.tax_credit_disallowed_year,
          'form1[0].page3[0].informationToReport[0].YearDisallowedReason[0].reasonDisallowed[0]' => @intake.cv_tax_credit_disallowed_reason,
          'form1[0].page3[0].informationToReport[0].eligibleLITCReferral[0]' => bool_checkbox(@intake.cv_eligible_for_litc_referral_cb_yes?),
          'form1[0].page3[0].informationToReport[0].estimatedTaxPayments[0].estimatedTaxPayments[0]' => bool_checkbox(@intake.cv_estimated_tax_payments_cb_yes?),
          'form1[0].page3[0].informationToReport[0].estimatedTaxPayments[0].taxPaymentsAmount[0]' => @intake.cv_estimated_tax_payments_amt.to_s,
          'form1[0].page3[0].informationToReport[0].lastYearsRefund[0].lastYearsRefund[0]' => bool_checkbox(@intake.cv_last_years_refund_applied_to_this_yr_cb_yes?),
          'form1[0].page3[0].informationToReport[0].lastYearsRefund[0].refundAmount[0]' => @intake.cv_last_years_refund_applied_to_this_yr_amt.to_s,
          'form1[0].page3[0].informationToReport[0].lastReturnAvailable[0]' => bool_checkbox(@intake.cv_last_years_return_available_cb_yes?),
          'form1[0].page3[0].informationReportComment[0].informationReportComment[0]' => @intake.cv_14c_page_3_notes_part_3,
      )

      answers.merge!(
        keep_and_normalize(
          {
            "form1[0].page1[0].presidentialElectionFund[0].presidentialElectionFundYou[0]" => (@intake.presidential_campaign_fund_donation_primary? || @intake.presidential_campaign_fund_donation_primary_and_spouse?),
            "form1[0].page3[0].q2[0].spouse[0]" => (@intake.presidential_campaign_fund_donation_spouse? || @intake.presidential_campaign_fund_donation_primary_and_spouse?),
            "form1[0].page1[0].presidentialElectionFund[0].presidentialElectionFundNo[0]" => (!(@intake.presidential_campaign_fund_donation_spouse? || @intake.presidential_campaign_fund_donation_primary_and_spouse?) && !(@intake.presidential_campaign_fund_donation_primary? || @intake.presidential_campaign_fund_donation_primary_and_spouse?)),
          }
        )
      )
      answers.merge!(demographic_info) if @intake.demographic_questions_opt_in_yes? || @intake.demographic_questions_hub_edit

      # ty2024 page 5

      answers["form1[0].page5[0].AdditionalComments[0].AdditionalNotesComments[0]"] = (@intake.additional_notes_comments || '') << "\n\n" << dependents_4th_and_up

      # end - ty2024 page 5

      answers
    end

    def vita_consent_to_disclose_info
      # aka form 15080 on page 4 info
      return {} unless @intake.primary_consented_to_service_at.present?

      data = {
        "form1[0].page6[0].primaryTaxpayer[0]" => @intake.primary.first_and_last_name,
        "form1[0].page6[0].primaryDateSigned[0]" => strftime_date(@intake.primary_consented_to_service_at),
      }
      if @intake.spouse_consented_to_service_at.present?
        data.merge!(
          "form1[0].page6[0].secondaryTaxpayer[0]" => @intake.spouse.first_and_last_name,
          "form1[0].page6[0].secondaryDateSigned[0]" => strftime_date(@intake.spouse_consented_to_service_at),
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
        keep_and_normalize(
          {
            "form1[0].page1[0].youSpouseWereIn[0].column2[0].holdDigitalAssets[0].digitalAssetsYou[0]" => @intake.primary_owned_or_held_any_digital_currencies_yes?,
            "form1[0].page1[0].youSpouseWereIn[0].column2[0].holdDigitalAssets[0].digitalAssetsSpouse[0]" => @intake.spouse_owned_or_held_any_digital_currencies_yes?,
            "form1[0].page1[0].youSpouseWereIn[0].column2[0].holdDigitalAssets[0].digitalAssetsNo[0]" => @intake.primary_owned_or_held_any_digital_currencies_no? && !@intake.spouse_owned_or_held_any_digital_currencies_yes?,
          },
          with_prefix("form1[0].page1[0].liveWorkStates[0]") do
            {
              "liveWorkYes[0]" => @intake.multiple_states_yes?,
              "liveWorkNo[0]" => @intake.multiple_states_no?,
            }
          end,
          with_prefix("form1[0].page1[0].youSpouseWereIn[0].column1[0].usCitizen[0]") do
            {
                "usCitizenYou[0]" => @intake.primary_us_citizen_yes?,
                "usCitizenSpouse[0]" => @intake.spouse_us_citizen_yes?,
                "usCitizenNo[0]" => @intake.primary_us_citizen_no? && !@intake.spouse_us_citizen_yes?,
            }
          end,
          with_prefix("form1[0].page1[0].youSpouseWereIn[0].column1[0].usOnVisa[0]") do
            {
              "onVisaYou[0]" => @intake.primary_visa_yes?,
              "onVisaSpouse[0]" => @intake.spouse_visa_yes?,
              "onVisaNo[0]" => @intake.primary_visa_no? && !@intake.spouse_visa_yes?
            }
          end,
          with_prefix('form1[0].page1[0].youSpouseWereIn[0].column1[0].fullTimeStudent[0]') do
            {
              "studentYou[0]" => @intake.was_full_time_student_yes?,
              "studentSpouse[0]" => @intake.spouse_was_full_time_student_yes?,
              "studentNo[0]" => @intake.was_full_time_student_no? && !@intake.spouse_was_full_time_student_yes?,
            }
          end,
          with_prefix("form1[0].page1[0].youSpouseWereIn[0].column2[0].legallyBlind[0]") do
            {
              "legallyBlindYou[0]" => @intake.was_blind_yes?,
              "legallyBlindSpouse[0]" => @intake.spouse_was_blind_yes?,
              "legallyBlindNo[0]" => @intake.was_blind_no? && !@intake.spouse_was_blind_yes?,
            }
          end,
          with_prefix("form1[0].page1[0].youSpouseWereIn[0].column2[0].totallyPermanentlyDisabled[0]") do
            {
              "disabledYou[0]" => @intake.had_disability_yes?,
              "disabledSpouse[0]" => @intake.spouse_had_disability_yes?,
              "disabledNo[0]" => @intake.had_disability_no? && !@intake.spouse_had_disability_yes?,
            }
          end,
          with_prefix("form1[0].page1[0].youSpouseWereIn[0].column2[0].issuedIdentityProtection[0]") do
            {
              "identityProtectionYou[0]" => @intake.issued_identity_pin_yes?,
              "identityProtectionSpouse[0]" => @intake.spouse_issued_identity_pin_yes?,
              "identityProtectionNo[0]" => @intake.issued_identity_pin_no? && !@intake.spouse_issued_identity_pin_yes?,
            }
          end,
          with_prefix("form1[0].page1[0].dueARefund[0]") do
            {
              'refundOther[0]' => @intake.refund_other_cb_yes?,
              "refundDirectDeposit[0]" => @intake.refund_direct_deposit_yes?,
              "refundCheckMail[0]" => @intake.refund_check_by_mail_yes?,
              "refundSplitAccounts[0]" => @intake.savings_split_refund_yes?,
            }
          end,
          with_prefix("form1[0].page1[0].haveBlanceDue[0]") do
            {
              "blanceBankAccount[0]" => @intake.balance_pay_from_bank_yes?,
              "blanceMailPayment[0]" => @intake.balance_pay_from_bank_no?,
            }
          end
        )
      )

      hash['form1[0].page1[0].dueARefund[0].refundOtherExplain[0]'] = @intake.refund_other

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
      keep_and_normalize(
        {
          # Appears not to be used in 2024 tax year
          # "form1[0].page3[0].q13[0].notAnswer[0]" => @intake.demographic_spouse_prefer_not_to_answer_race,
          # "form1[0].page3[0].q13[0].noSpouse[0]" => nil,
        },
        with_prefix("form1[0].page4[0].optionalQuestions[0].carryConversationEnglish[0]") do
          {
            "veryWell[0]" => @intake.demographic_english_conversation_very_well?,
            "well[0]" => @intake.demographic_english_conversation_well?,
            "notWell[0]" => @intake.demographic_english_conversation_not_well?,
            "notAtAll[0]" => @intake.demographic_english_conversation_not_at_all?,
            "notAnswer[0]" => @intake.demographic_english_conversation_prefer_not_to_answer?,
          }
        end,
        with_prefix("form1[0].page4[0].optionalQuestions[0].readNewspaperEnglish[0]") do
          {
            "veryWell[0]" => @intake.demographic_english_reading_very_well?,
            "well[0]" => @intake.demographic_english_reading_well?,
            "notWell[0]" => @intake.demographic_english_reading_not_well?,
            "notAtAll[0]" => @intake.demographic_english_reading_not_at_all?,
            "notAnswer[0]" => @intake.demographic_english_reading_prefer_not_to_answer?,
          }
        end,
        with_prefix("form1[0].page4[0].optionalQuestions[0].memberHouseholdDisability[0]") do
          {
            "disabilityYes[0]" => @intake.demographic_disability_yes?,
            "disabilityNo[0]" => @intake.demographic_disability_no?,
            "notAnswer[0]" => @intake.demographic_disability_prefer_not_to_answer?,

          }
        end,
        with_prefix("form1[0].page4[0].optionalQuestions[0].youSpouseVeteran[0]") do
          {
            "veteranYes[0]" => @intake.demographic_veteran_yes?,
            "veteranNo[0]" => @intake.demographic_veteran_no?,
            "notAnswer[0]" => @intake.demographic_veteran_prefer_not_to_answer?,
          }
        end,
        with_prefix("form1[0].page4[0].yourRaceEthnicity[0]") do
          {
            "americanIndian[0]" => @intake.demographic_primary_american_indian_alaska_native?,
            "asian[0]" => @intake.demographic_primary_asian?,
            "blackAfricanAmerican[0]" => @intake.demographic_primary_black_african_american?,
            "hispanicLatino[0]" => @intake.demographic_primary_hispanic_latino?,
            "middleEsternNorthAfrican[0]" => @intake.demographic_primary_mena?,
            "hawaiianPacific[0]" => @intake.demographic_primary_native_hawaiian_pacific_islander?,
            "white[0]" => @intake.demographic_primary_white?,
          }
        end,
        with_prefix("form1[0].page4[0].yourSpousesRaceEthnicity[0]") do
          {
            "americanIndian[0]" => @intake.demographic_spouse_american_indian_alaska_native?,
            "asian[0]" => @intake.demographic_spouse_asian?,
            "blackAfricanAmerican[0]" => @intake.demographic_spouse_black_african_american?,
            "hispanicLatino[0]" => @intake.demographic_spouse_hispanic_latino?,
            "middleEsternNorthAfrican[0]" => @intake.demographic_spouse_mena?,
            "hawaiianPacific[0]" => @intake.demographic_spouse_native_hawaiian_pacific_islander?,
            "white[0]" => @intake.demographic_spouse_white?,
          }
        end
      )
    end

    private

    # Trims the hash to only the values as tested by the block, which should
    # return true if keeping. Additionally, it normalizes the value to the
    # value specified.
    # 
    # @see {Enumerable#keep_if}
    # @see {Hash#transform_values}
    #
    # @param pdf_hash [Hash, Array] Either an array of hashes or a hash. When given an array, it will merge each hash together
    # @param normalize_to [Proc, Any] Either a literal value to normalize to or a callable to call on the value to normalize. Defaults to "1"
    # @param keep_if [Proc] Passed literally to Hash#keep_if. Defaults to a truthiness check on value
    # @return [Hash]
    def keep_and_normalize(*pdf_hash, normalize_to: "1", keep_if: ->(_k, v) { v })
      if pdf_hash.is_a?(Array)
        pdf_hash = pdf_hash.reduce(&:merge)
      end

      normalizer = if normalize_to.respond_to?(:call)
                     normalize_to
                   else
                     proc { normalize_to }
                   end

      pdf_hash.keep_if(&keep_if).transform_values(&normalizer)
    end

    # Adds a prefix to hash keys. Used to group related answers to a given question
    #
    # @param field_prefix [String] A prefix string
    # @yield [] Should return a hash
    # @return [Hash] The resulting hash with keys transformed
    def with_prefix(field_prefix)
      hash = yield

      hash.transform_keys! {|k| "#{field_prefix}.#{k}"}
    end

    def single_dependent_params(dependent, index:)
      {
        "form1[0].page1[0].namesOf[0].Row#{index}[0].nameFirstLast[0]" => dependent.full_name,
        "form1[0].page1[0].namesOf[0].Row#{index}[0].dateOfBirth[0]" => strftime_date(dependent.birth_date),
        "form1[0].page1[0].namesOf[0].Row#{index}[0].relationshipToYou[0]" => dependent.relationship,
        "form1[0].page1[0].namesOf[0].Row#{index}[0].monthsLivedHome[0]" => dependent.months_in_home.to_s,
        "form1[0].page1[0].namesOf[0].Row#{index}[0].singleMarried[0]" => married_to_SM(dependent.was_married),
        "form1[0].page1[0].namesOf[0].Row#{index}[0].usCitizen[0]" => yes_no_unfilled_to_YN(dependent.us_citizen),
        "form1[0].page1[0].namesOf[0].Row#{index}[0].residentUSCandaMexico[0]" => yes_no_unfilled_to_YN(dependent.north_american_resident),
        "form1[0].page1[0].namesOf[0].Row#{index}[0].fullTimeStudent[0]" => yes_no_unfilled_to_YN(dependent.was_student),
        "form1[0].page1[0].namesOf[0].Row#{index}[0].totallyPermanentlyDisabled[0]" => yes_no_unfilled_to_YN(dependent.disabled),
        "form1[0].page1[0].namesOf[0].Row#{index}[0].issuedIPPIN[0]" => yes_no_unfilled_to_YN(dependent.has_ip_pin),
        # certified volunteer section
        "form1[0].page1[0].namesOf[0].Row#{index}[0].qualifyingChildDependent[0]" => yes_no_na_unfilled_to_Yes_No_NA(dependent.can_be_claimed_by_other),
        "form1[0].page1[0].namesOf[0].Row#{index}[0].ownSupport[0]" => yes_no_na_unfilled_to_Yes_No_NA(dependent.provided_over_half_own_support),
        "form1[0].page1[0].namesOf[0].Row#{index}[0].lessThanIncome[0]" => yes_no_na_unfilled_to_Yes_No_NA(dependent.below_qualifying_relative_income_requirement),
        "form1[0].page1[0].namesOf[0].Row#{index}[0].supportForPerson[0]" => yes_no_na_unfilled_to_Yes_No_NA(dependent.filer_provided_over_half_support),
        "form1[0].page1[0].namesOf[0].Row#{index}[0].costMaintainingHome[0]" => yes_no_na_unfilled_to_Yes_No_NA(dependent.filer_provided_over_half_housing_support),
      }
    end

    def dependents_4th_and_up
      return '' if @dependents.length < 4

      s = "Additional Dependents:\n"
      sep = ' // '

      @dependents[3..].map do |dependent|
        s << dependent.full_name << sep
        s << strftime_date(dependent.birth_date) << sep
        s << dependent.relationship << sep
        s << 'Months lived in home in 2024: ' << dependent.months_in_home.to_s << sep
        s << 'Single or married in 2024: ' << married_to_SM(dependent.was_married) << sep
        s << 'US citizen: ' << yes_no_unfilled_to_YN(dependent.us_citizen) << sep
        s << 'Resident of US/Canada/Mexico: ' << yes_no_unfilled_to_YN(dependent.north_american_resident) << sep
        s << 'FT student: ' << yes_no_unfilled_to_YN(dependent.was_student) << sep
        s << 'Disabled: ' << yes_no_unfilled_to_YN(dependent.disabled) << sep
        s << 'Issued IPPIN: ' << yes_no_unfilled_to_YN(dependent.has_ip_pin) << sep

        # gray fields
        s << 'Qualifying child or relative of any other person: ' <<  yes_no_na_unfilled_to_YNNA(dependent.can_be_claimed_by_other) << sep
        s << 'Provided more than 50% of their own support: ' << yes_no_na_unfilled_to_YNNA(dependent.provided_over_half_own_support) << sep
        s << 'Had less than $5,050 income: ' << yes_no_na_unfilled_to_YNNA(dependent.below_qualifying_relative_income_requirement) << sep
        s << 'Taxpayer(s) provided more than 50% of support: ' << yes_no_na_unfilled_to_YNNA(dependent.filer_provided_over_half_support) << sep
        s << 'Taxpayer(s) paid more than half the cost of maintaining home for this person: ' << yes_no_na_unfilled_to_YNNA(dependent.filer_provided_over_half_housing_support) << "\n\n"
      end.join()

      s
    end

    def yes_no_unfilled_to_YN(yes_no_unfilled)
      {
        "yes" => "Y",
        "no" => "N",
        "unfilled" => ""
      }[yes_no_unfilled]
    end

    def yes_no_na_unfilled_to_Yes_No_NA(yes_no_na_unfilled)
      {
        "yes" => "Yes",
        "no" => "No",
        "na" => "N/A",
        "unfilled" => ""
      }[yes_no_na_unfilled]
    end

    def yes_no_na_unfilled_to_YNNA(yes_no_na_unfilled)
      {
        "yes" => "Y",
        "no" => "N",
        "na" => "N/A",
        "unfilled" => ""
      }[yes_no_na_unfilled]
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
