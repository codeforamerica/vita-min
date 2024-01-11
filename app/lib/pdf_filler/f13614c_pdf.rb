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
      "f13614c-TY2023"
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
      answers.merge!(primary_info)
      answers.merge!(spouse_info)
      answers.merge!(dependents_info) if @dependents.present?
      answers.merge!(
        "form1[0].page1[0].q3_Mailing_Address[0]" => @intake.street_address,
        "form1[0].page1[0].p3_Apartment_Number[0]" => @intake.street_address2,
        "form1[0].page1[0].q3_City[0]" => @intake.city,
        "form1[0].page1[0].q3_State[0]" => @intake.state&.upcase,
        "form1[0].page1[0].q3_ZIP_Code[0]" => @intake.zip_code,
      )
      answers.merge!(
        yes_no_checkboxes("form1[0].page1[0].q10_Can_Anyone_Claim[0]", @intake.claimed_by_another, include_unsure: true),
        yes_no_checkboxes("form1[0].page1[0].q11_Have_You_Or[0]", collective_yes_no_unsure(@intake.issued_identity_pin, @intake.spouse_issued_identity_pin))
      )
      answers.merge!(
        "form1[0].page1[0].q12_Email_Address[0]" => @intake.email_address,
        "form1[0].page1[0].q1_As_of_December[0].never_married[0]" => yes_no_unfilled_to_opposite_checkbox(@intake.ever_married),
        "form1[0].page1[0].q1_As_of_December[0].married[0]" => yes_no_unfilled_to_checkbox(fetch_gated_value(@intake, :married)),
      )
      answers.merge!(
        yes_no_checkboxes("form1[0].page1[0].q1_As_of_December[0].q1a_Get_Married[0]", @intake.got_married_during_tax_year),
        yes_no_checkboxes("form1[0].page1[0].q1_As_of_December[0].q1b_Live_With[0]", fetch_gated_value(@intake, :lived_with_spouse)),
      )
      answers.merge!(
        "form1[0].page1[0].q1_As_of_December[0].divorced[0]" => yes_no_unfilled_to_checkbox(fetch_gated_value(@intake, :divorced)),
        "form1[0].page1[0].q1_As_of_December[0].Date_Of_Final[0]" => @intake.divorced_year,
        "form1[0].page1[0].q1_As_of_December[0].legally_separated[0]" => yes_no_unfilled_to_checkbox(fetch_gated_value(@intake, :separated)),
        "form1[0].page1[0].q1_As_of_December[0].Date_Of_Separate[0]" => @intake.separated_year,
        "form1[0].page1[0].q1_As_of_December[0].widowed[0]" => yes_no_unfilled_to_checkbox(fetch_gated_value(@intake, :widowed)),
        "form1[0].page1[0].q1_As_of_December[0].Year_Of_Death[0]" => @intake.widowed_year,
        "form1[0].page1[0].additionalSpace[0].additional_space[0]" => @dependents.length > 3 ? "1" : nil,
      )
      answers.merge!(
        yes_no_checkboxes("form1[0].page2[0].Part_3[0].q1_Wages_Or_Salary[0]", @intake.had_wages, include_unsure: true)
      )
      answers.merge!(
        "form1[0].page2[0].Part_3[0].q1_Wages_Or_Salary[0].Number_of_Jobs[0]" => @intake.job_count.to_s,
      )
      answers.merge!(
        yes_no_checkboxes("form1[0].page2[0].Part_3[0].q2_Tip_Income[0]", @intake.had_tips, include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part_3[0].q3_Scholarships[0]", @intake.had_scholarships, include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part_3[0].q4_Interest_Dividends_From[0]", @intake.had_interest_income, include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part_3[0].q5_Refund_Of_State[0]", fetch_gated_value(@intake, :had_local_tax_refund), include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part_3[0].q6_Alimony_Income[0]", fetch_gated_value(@intake, :received_alimony), include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part_3[0].q7_Self-Employment_Income[0]", @intake.had_self_employment_income, include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part_3[0].q8_Cash_Check_Payments[0]", @intake.had_cash_check_digital_assets, include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part_3[0].q9_Income[0]", collective_yes_no_unsure(fetch_gated_value(@intake, :had_asset_sale_income), fetch_gated_value(@intake, :reported_asset_sale_loss), fetch_gated_value(@intake, :sold_a_home)), include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part_3[0].q10_Disability_Income[0]", @intake.had_disability_income, include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part_3[0].q11_Retirement_Income[0]", fetch_gated_value(@intake, :had_retirement_income), include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part_3[0].q12_Unemployment_Compensation[0]", @intake.had_unemployment_income, include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part_3[0].q13_Social_Security_Or[0]", fetch_gated_value(@intake, :had_social_security_income), include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part_3[0].q14_Income_or_Loss[0]", @intake.had_rental_income, include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part_3[0].q15_Other_Income[0]", collective_yes_no_unsure(@intake.had_other_income, fetch_gated_value(@intake, :had_gambling_income)), include_unsure: true),

        yes_no_checkboxes("form1[0].page2[0].Part_4[0].q1_Alimony[0]", fetch_gated_value(@intake, :paid_alimony), include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part_4[0].q1_Alimony[0].If_Yes[0]", @intake.has_ssn_of_alimony_recipient),

        yes_no_checkboxes("form1[0].page2[0].Part_4[0].q2_Contributions[0]", fetch_gated_value(@intake, :paid_retirement_contributions), include_unsure: true),
      )
      answers.merge!(
        "form1[0].page2[0].Part_4[0].q2_Contributions[0].IRA[0]" => yes_no_unfilled_to_checkbox(@intake.contributed_to_ira),
        "form1[0].page2[0].Part_4[0].q2_Contributions[0].Roth_IRA[0]" => yes_no_unfilled_to_checkbox(@intake.contributed_to_roth_ira),
        "form1[0].page2[0].Part_4[0].q2_Contributions[0]._401K[0]" => yes_no_unfilled_to_checkbox(@intake.contributed_to_401k),
        "form1[0].page2[0].Part_4[0].q2_Contributions[0].Other[0]" => yes_no_unfilled_to_checkbox(@intake.contributed_to_other_retirement_account),
      )

      answers.merge!(
        yes_no_checkboxes("form1[0].page2[0].Part_4[0].q3_Post_Secondary[0]", @intake.paid_post_secondary_educational_expenses, include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part_4[0].q4_Deductions[0]", @intake.wants_to_itemize, include_unsure: true),
      )
      answers.merge!(
        "form1[0].page2[0].Part_4[0].q4_Deductions[0].taxes[0]" => yes_no_unfilled_to_checkbox(fetch_gated_value(@intake, :paid_local_tax)),
        "form1[0].page2[0].Part_4[0].q4_Deductions[0].mortgage[0]" => yes_no_unfilled_to_checkbox(fetch_gated_value(@intake, :paid_mortgage_interest)),
        "form1[0].page2[0].Part_4[0].q4_Deductions[0].medical[0]" => yes_no_unfilled_to_checkbox(fetch_gated_value(@intake, :paid_medical_expenses)),
        "form1[0].page2[0].Part_4[0].q4_Deductions[0].charitable[0]" => yes_no_unfilled_to_checkbox(fetch_gated_value(@intake ,:paid_charitable_contributions)),
      )
      answers.merge!(
        yes_no_checkboxes("form1[0].page2[0].Part_4[0].q5_Child_Or_Dependent[0]", fetch_gated_value(@intake, :paid_dependent_care), include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part_4[0].q6_For_Supplies_Used[0]", fetch_gated_value(@intake, :paid_school_supplies), include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part_4[0].q7_Expenses_Related_To[0]", @intake.paid_self_employment_expenses, include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part_4[0].q8_Student_Loan_Interest[0]", @intake.paid_student_loan_interest, include_unsure: true),

        yes_no_checkboxes("form1[0].page2[0].Part_5[0].q1_Have_A_Health[0]", @intake.had_hsa, include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part_5[0].q2_Have_Debt_From[0]", @intake.had_debt_forgiven, include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part_5[0].q3_Adopt_A_Child[0]", fetch_gated_value(@intake, :adopted_child), include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part_5[0].q4_Have_Earned_Income[0]", @intake.had_tax_credit_disallowed, include_unsure: true),
      )
      answers.merge!(
        "form1[0].page2[0].Part_5[0].q4_Have_Earned_Income[0].Which_Tax_Year[0]" => @intake.tax_credit_disallowed_year,
      )
      answers.merge!(
        yes_no_checkboxes("form1[0].page2[0].Part_5[0].q5_Purchase_And_Install[0]", @intake.bought_energy_efficient_items || "unfilled", include_unsure: true), # no default in db
        yes_no_checkboxes("form1[0].page2[0].Part_5[0].q6_Receive_The_First[0]", fetch_gated_value(@intake, :received_homebuyer_credit), include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part_5[0].q7_Make_Estimated_Tax[0]", @intake.made_estimated_tax_payments, include_unsure: true),
      )
      answers.merge!(
        "form1[0].page2[0].Part_5[0].q7_Make_Estimated_Tax[0].How_Much[0]" => @intake.made_estimated_tax_payments_amount,
      )
      answers.merge!(
        yes_no_checkboxes("form1[0].page2[0].Part_5[0].q8_File_A_Federal[0]", @intake.had_capital_loss_carryover, include_unsure: true),
        yes_no_checkboxes("form1[0].page2[0].Part_5[0].q9_have_health[0]", @intake.bought_marketplace_health_insurance, include_unsure: true),
      )
      answers.merge!(
        # Additional Information Section
        yes_no_checkboxes("form1[0].page3[0].q1[0]", @intake.preferred_written_language.present? ? "yes" : "no"),
      )
      answers.merge!(
        "form1[0].page3[0].q1[0].Which_Language[0]" => @intake.preferred_written_language,
        "form1[0].page3[0].q2[0].you[0]" => (@intake.presidential_campaign_fund_donation_primary? || @intake.presidential_campaign_fund_donation_primary_and_spouse?) ? "1" : "Off",
        "form1[0].page3[0].q2[0].spouse[0]" => (@intake.presidential_campaign_fund_donation_spouse? || @intake.presidential_campaign_fund_donation_primary_and_spouse?) ? "1" : "Off",
      )
      answers.merge!(
        yes_no_checkboxes("form1[0].page3[0].q3[0].Direct_Deposit[0]", determine_direct_deposit(@intake)),
        yes_no_checkboxes("form1[0].page3[0].q3[0].Savings_Bonds[0]", @intake.savings_purchase_bond),
        yes_no_checkboxes("form1[0].page3[0].q3[0].Different_Accounts[0]", @intake.savings_split_refund),
        yes_no_checkboxes("form1[0].page3[0].q4[0]", @intake.balance_pay_from_bank),
        yes_no_checkboxes("form1[0].page3[0].q5[0]", @intake.had_disaster_loss),
      )
      answers.merge!(
        "form1[0].page3[0].q5[0].If_Yes_Where[0]" => @intake.had_disaster_loss_where,
      )
      answers.merge!(
        yes_no_checkboxes("form1[0].page3[0].q6[0]", @intake.received_irs_letter),
        yes_no_checkboxes("form1[0].page3[0].q7[0]", @intake.register_to_vote),
      )
      answers.merge!(demographic_info) if @intake.demographic_questions_opt_in_yes? || @intake.demographic_questions_hub_edit
      answers.merge!(
        "form1[0].page3[0].Additional_Comments[0].Additional_Comments[1]" => additional_comments,
      )
      answers
    end

    def primary_info
      {
        "form1[0].page1[0].q1_Your_First_Name[0]" => @intake.primary.first_name,
        "form1[0].page1[0].q1_Your_Middle_Initial[0]" => @intake.primary.middle_initial,
        "form1[0].page1[0].q1_Your_Last_Name[0]" => @intake.primary.last_name,
        "form1[0].page1[0].q4_Your_Date_Birth[0]" => strftime_date(@intake.primary.birth_date),
        "form1[0].page1[0].q1_Telephone_Number[0]" => @intake.formatted_phone_number,
        "form1[0].page1[0].q5_Your_Job_Title[0]" => @intake.primary_job_title,
      }.merge(
        yes_no_checkboxes("form1[0].page1[0].q1_Are_You_A[0]", @intake.primary_us_citizen),
        yes_no_checkboxes("form1[0].page1[0].q6_Are_You[0].q6a_Full_Time_Student[0]", @intake.was_full_time_student),
        yes_no_checkboxes("form1[0].page1[0].q6_Are_You[0].q6b_Totally_Permanently_Disabled[0]", @intake.had_disability),
        yes_no_checkboxes("form1[0].page1[0].q6_Are_You[0].q6c_Legally_Blind[0]", @intake.was_blind),
      )
    end

    def yes_no_checkboxes(pdf_key_base, enum_value, include_unsure: false)
      result = {
        "#{pdf_key_base}.yes[0]" => enum_value == "yes" ? "1" : "Off",
        "#{pdf_key_base}.no[0]" => enum_value == "no" ? "1" : "Off",
      }
      if include_unsure
        result.merge!(
          "#{pdf_key_base}.unsure[0]" => enum_value == "unsure" ? "1" : "Off",
        )
      end
      result
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
        "form1[0].page1[0].q2_Spouse_First_Name[0]" => @intake.spouse.first_name,
        "form1[0].page1[0].q2_Spouse_Middle_Initial[0]" => @intake.spouse.middle_initial,
        "form1[0].page1[0].q2_Spouse_Last_Name[0]" => @intake.spouse.last_name,
        "form1[0].page1[0].q2_Telephone_Number[0]" => @intake.spouse_phone_number,
        "form1[0].page1[0].q7_Spouse_Date_Birth[0]" => strftime_date(@intake.spouse.birth_date),
        "form1[0].page1[0].q8_Spouse_Job_Title[0]" => @intake.spouse_job_title,
      }.merge(
        yes_no_checkboxes("form1[0].page1[0].q2_Is_Your_Spouse[0]", @intake.spouse_us_citizen),
        yes_no_checkboxes("form1[0].page1[0].q9_Is_Your_Spouse[0].q9a_Full_Time_Student[0]", @intake.spouse_was_full_time_student),
        yes_no_checkboxes("form1[0].page1[0].q9_Is_Your_Spouse[0].q9b_Totally_Permanently_Disabled[0]", @intake.spouse_had_disability),
        yes_no_checkboxes("form1[0].page1[0].q9_Is_Your_Spouse[0].q9c_Legally_Blind[0]", @intake.spouse_was_blind),
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
        "form1[0].page3[0].q8[0].very_well[0]" => @intake.demographic_english_conversation_very_well? ? '1' : nil,
        "form1[0].page3[0].q8[0].well[0]" => @intake.demographic_english_conversation_well? ? '1' : nil,
        "form1[0].page3[0].q8[0].not_well[0]" => @intake.demographic_english_conversation_not_well? ? '1' : nil,
        "form1[0].page3[0].q8[0].not_at_all[0]" => @intake.demographic_english_conversation_not_at_all? ? '1' : nil,
        "form1[0].page3[0].q8[0].not_answer[0]" => @intake.demographic_english_conversation_prefer_not_to_answer? ? '1' : nil,

        "form1[0].page3[0].q9[0].very_well[0]" => @intake.demographic_english_reading_very_well? ? '1' : nil,
        "form1[0].page3[0].q9[0].well[0]" => @intake.demographic_english_reading_well? ? '1' : nil,
        "form1[0].page3[0].q9[0].not_well[0]" => @intake.demographic_english_reading_not_well? ? '1' : nil,
        "form1[0].page3[0].q9[0].not_at_all[0]" => @intake.demographic_english_reading_not_at_all? ? '1' : nil,
        "form1[0].page3[0].q9[0].not_answer[0]" => @intake.demographic_english_reading_prefer_not_to_answer? ? '1' : nil,

        "form1[0].page3[0].q10[0].yes[0]" => @intake.demographic_disability_yes? ? '1' : nil,
        "form1[0].page3[0].q10[0].no[0]" => @intake.demographic_disability_no? ? '1' : nil,
        "form1[0].page3[0].q10[0].not_answer[0]" => @intake.demographic_disability_prefer_not_to_answer? ? '1' : nil,

        "form1[0].page3[0].q11[0].yes[0]" => @intake.demographic_veteran_yes? ? '1' : nil,
        "form1[0].page3[0].q11[0].no[0]" => @intake.demographic_veteran_no? ? '1' : nil,
        "form1[0].page3[0].q11[0].not_answer[0]" => @intake.demographic_veteran_prefer_not_to_answer? ? '1' : nil,

        "form1[0].page3[0].q12[0].american_indian[0]" => bool_checkbox(@intake.demographic_primary_american_indian_alaska_native),
        "form1[0].page3[0].q12[0].asian[0]" => bool_checkbox(@intake.demographic_primary_asian),
        "form1[0].page3[0].q12[0].black_african[0]" => bool_checkbox(@intake.demographic_primary_black_african_american),
        "form1[0].page3[0].q12[0].native_hawaiian[0]" => bool_checkbox(@intake.demographic_primary_native_hawaiian_pacific_islander),
        "form1[0].page3[0].q12[0].white[0]" => bool_checkbox(@intake.demographic_primary_white),
        "form1[0].page3[0].q12[0].not_answer[0]" => bool_checkbox(@intake.demographic_primary_prefer_not_to_answer_race),

        "form1[0].page3[0].q13[0].american_indian[0]" => bool_checkbox(@intake.demographic_spouse_american_indian_alaska_native),
        "form1[0].page3[0].q13[0].asian[0]" => bool_checkbox(@intake.demographic_spouse_asian),
        "form1[0].page3[0].q13[0].black_african[0]" => bool_checkbox(@intake.demographic_spouse_black_african_american),
        "form1[0].page3[0].q13[0].native_hawaiian[0]" => bool_checkbox(@intake.demographic_spouse_native_hawaiian_pacific_islander),
        "form1[0].page3[0].q13[0].white[0]" => bool_checkbox(@intake.demographic_spouse_white),
        "form1[0].page3[0].q13[0].not_answer[0]" => bool_checkbox(@intake.demographic_spouse_prefer_not_to_answer_race),
        "form1[0].page3[0].q13[0].no_spouse[0]" => nil,

        "form1[0].page3[0].q14[0].hispanic_latino[0]" => bool_checkbox(@intake.demographic_primary_ethnicity_hispanic_latino?),
        "form1[0].page3[0].q14[0].not_hispanic_latino[0]" => bool_checkbox(@intake.demographic_primary_ethnicity_not_hispanic_latino?),
        "form1[0].page3[0].q14[0].not_answer[0]" => bool_checkbox(@intake.demographic_primary_ethnicity_prefer_not_to_answer?),

        "form1[0].page3[0].q15[0].hispanic_latino[0]" => bool_checkbox(@intake.demographic_spouse_ethnicity_hispanic_latino?),
        "form1[0].page3[0].q15[0].not_hispanic_latino[0]" => bool_checkbox(@intake.demographic_spouse_ethnicity_not_hispanic_latino?),
        "form1[0].page3[0].q15[0].not_answer[0]" => bool_checkbox(@intake.demographic_spouse_ethnicity_prefer_not_to_answer?),
        "form1[0].page3[0].q15[0].no_spouse[0]" => nil,
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
