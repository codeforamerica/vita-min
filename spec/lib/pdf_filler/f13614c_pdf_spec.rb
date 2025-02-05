require "rails_helper"

RSpec.describe PdfFiller::F13614cPdf do
  include PdfSpecHelper

  let(:intake_pdf) { described_class.new(intake) }

  describe "#output_file" do
    context "with a complete intake record and disclose consented" do
      let(:intake) do
        create(
          :intake,
          client: build(:client, :with_consent, consented_to_service_at: Date.new(2024, 1, 1)),
          additional_notes_comments: "if there is another gnome living in my garden but only i have an income, does that make me head of household?",
          adopted_child: "no",
          advance_ctc_amount_received: 500,
          balance_pay_from_bank: "no",
          bought_energy_efficient_items: "unsure",
          bought_marketplace_health_insurance: "yes",
          city: "Gardenia",
          claimed_by_another: "no",
          contributed_to_401k: "yes",
          contributed_to_ira: "no",
          contributed_to_other_retirement_account: "no",
          contributed_to_roth_ira: "yes",
          demographic_disability: "yes",
          demographic_english_conversation: "well",
          demographic_english_reading: "not_well",
          demographic_primary_american_indian_alaska_native: false,
          demographic_primary_asian: false,
          demographic_primary_black_african_american: false,
          demographic_primary_ethnicity: "not_hispanic_latino",
          demographic_primary_native_hawaiian_pacific_islander: true,
          demographic_primary_prefer_not_to_answer_race: nil,
          demographic_primary_white: true,
          demographic_questions_opt_in: "yes",
          demographic_spouse_american_indian_alaska_native: true,
          demographic_spouse_asian: false,
          demographic_spouse_black_african_american: false,
          demographic_spouse_ethnicity: "not_hispanic_latino",
          demographic_spouse_native_hawaiian_pacific_islander: false,
          demographic_spouse_prefer_not_to_answer_race: nil,
          demographic_spouse_white: false,
          demographic_veteran: "no",
          divorced: "no",
          divorced_year: "2015",
          eip1_amount_received: 500,
          eip2_amount_received: 1500,
          eip3_amount_received: 2500,
          email_address: "hoofie@heifer.horse",
          ever_married: "yes",
          ever_owned_home: "no",
          filing_joint: "yes",
          had_asset_sale_income: "yes",
          had_capital_loss_carryover: "no",
          had_cash_check_digital_assets: "no",
          had_debt_forgiven: "yes",
          had_disability: "yes",
          had_disability_income: "no",
          had_disaster_loss: "yes",
          had_disaster_loss_where: "Athens",
          had_farm_income: "no",
          had_gambling_income: "yes",
          had_hsa: "no",
          had_interest_income: "yes",
          had_local_tax_refund: "yes",
          had_other_income: "yes",
          had_rental_income: "yes",
          had_retirement_income: "yes",
          had_scholarships: "yes",
          had_self_employment_income: "yes",
          had_social_security_income: "yes",
          had_tax_credit_disallowed: "yes",
          had_tips: "yes",
          had_unemployment_income: "yes",
          had_wages: "yes",
          has_ssn_of_alimony_recipient: "yes",
          issued_identity_pin: "no",
          job_count: 5,
          lived_with_spouse: "yes",
          made_estimated_tax_payments: "unsure",
          made_estimated_tax_payments_amount: 0,
          married: "yes",
          multiple_states: "yes",
          other_income_types: "garden gnoming",
          paid_alimony: "yes",
          paid_charitable_contributions: "no",
          paid_dependent_care: "unfilled",
          paid_local_tax: "yes",
          paid_medical_expenses: "yes",
          paid_mortgage_interest: "unfilled",
          paid_post_secondary_educational_expenses: "yes",
          paid_retirement_contributions: "unsure",
          paid_school_supplies: "yes",
          paid_self_employment_expenses: "no",
          paid_student_loan_interest: "yes",
          phone_number: "+14158161286",
          preferred_written_language: "ru",
          presidential_campaign_fund_donation: "primary",
          primary_birth_date: Date.new(1961, 4, 19),
          primary_consented_to_service: "yes",
          primary_first_name: "Hoofie",
          primary_last_name: "Heifer",
          primary_us_citizen: "no",
          receive_written_communication: "yes",
          received_advance_ctc_payment: "yes",
          received_alimony: "yes",
          received_homebuyer_credit: "unfilled", # ever_owned_home
          received_irs_letter: "no",
          received_stimulus_payment: "yes",
          refund_payment_method: "direct_deposit",
          register_to_vote: "no",
          reported_asset_sale_loss: "yes",
          reported_self_employment_loss: "yes",
          savings_purchase_bond: "yes",
          savings_split_refund: "no",
          separated: "no",
          separated_year: "2016",
          sold_a_home: "unfilled",
          spouse_birth_date: Date.new(1959, 11, 1),
          spouse_consented_to_service: "yes",
          spouse_first_name: "Hattie",
          spouse_had_disability: "no",
          spouse_issued_identity_pin: "no",
          spouse_last_name: "Heifer",
          spouse_us_citizen: "yes",
          spouse_was_blind: "no",
          spouse_was_full_time_student: "yes",
          state: "nj",
          street_address: "789 Garden Green Ln",
          tax_credit_disallowed_year: 2018,
          wants_to_itemize: "yes",
          was_blind: "no",
          was_full_time_student: "no",
          widowed: "no",
          widowed_year: "2017",
          zip_code: "08052",
          spouse_consented_to_service_at: Date.new(2024, 1, 1),
        )
      end
      before do
        create(
          :dependent,
          intake: intake,
          first_name: "Percy",
          last_name: "Pony",
          relationship: "Child",
          birth_date: Date.new(2005, 3, 2),
          months_in_home: 12,
          was_married: "no",
          disabled: "no",
          north_american_resident: "yes",
          us_citizen: "yes",
          was_student: "no",
          can_be_claimed_by_other: "yes",
          provided_over_half_own_support: "no",
          below_qualifying_relative_income_requirement: "yes",
          filer_provided_over_half_support: "yes",
          filer_provided_over_half_housing_support: "na",
          has_ip_pin: "yes",
        )
        create(
          :dependent,
          intake: intake,
          first_name: "Parker",
          last_name: "Pony",
          relationship: "Some kid at my house",
          birth_date: Date.new(2001, 12, 10),
          months_in_home: 4,
          was_married: "yes",
          disabled: "no",
          north_american_resident: "yes",
          us_citizen: "yes",
          was_student: "yes",
          can_be_claimed_by_other: "no",
          provided_over_half_own_support: "na",
          below_qualifying_relative_income_requirement: "yes",
          filer_provided_over_half_support: "na",
          filer_provided_over_half_housing_support: "yes",
          has_ip_pin: "no",
        )
        create(
          :dependent,
          intake: intake,
          first_name: "Penny",
          last_name: "Pony",
          relationship: "Progeny",
          birth_date: Date.new(2010, 10, 15),
          months_in_home: 12,
          was_married: "no",
          disabled: "yes",
          north_american_resident: "yes",
          us_citizen: "no",
          was_student: "no",
          can_be_claimed_by_other: "no",
          provided_over_half_own_support: "yes",
          below_qualifying_relative_income_requirement: "na",
          filer_provided_over_half_support: "na",
          filer_provided_over_half_housing_support: "yes",
        )
      end

      it 'fills out the dependent info section on page 1 correctly' do
        output_file = intake_pdf.output_file
        result = non_preparer_fields(output_file.path)
        expect(result).to include(
                            # dependent 1
                            "form1[0].page1[0].namesOf[0].Row1[0].nameFirstLast[0]" => "Percy Pony",
                            "form1[0].page1[0].namesOf[0].Row1[0].dateOfBirth[0]" => "3/2/2005",
                            "form1[0].page1[0].namesOf[0].Row1[0].relationshipToYou[0]" => "Child",
                            "form1[0].page1[0].namesOf[0].Row1[0].monthsLivedHome[0]" => "12",
                            "form1[0].page1[0].namesOf[0].Row1[0].singleMarried[0]" => "S",
                            "form1[0].page1[0].namesOf[0].Row1[0].usCitizen[0]" => "Y",
                            "form1[0].page1[0].namesOf[0].Row1[0].residentUSCandaMexico[0]" => "Y",
                            "form1[0].page1[0].namesOf[0].Row1[0].fullTimeStudent[0]" => "N",
                            "form1[0].page1[0].namesOf[0].Row1[0].totallyPermanentlyDisabled[0]" => "N",
                            "form1[0].page1[0].namesOf[0].Row1[0].issuedIPPIN[0]" => "Y",
                            # dependent 2
                            "form1[0].page1[0].namesOf[0].Row2[0].nameFirstLast[0]" => "Parker Pony",
                            "form1[0].page1[0].namesOf[0].Row2[0].dateOfBirth[0]" => "12/10/2001",
                            "form1[0].page1[0].namesOf[0].Row2[0].relationshipToYou[0]" => "Some kid at my house",
                            "form1[0].page1[0].namesOf[0].Row2[0].monthsLivedHome[0]" => "4",
                            "form1[0].page1[0].namesOf[0].Row2[0].singleMarried[0]" => "M",
                            "form1[0].page1[0].namesOf[0].Row2[0].usCitizen[0]" => "Y",
                            "form1[0].page1[0].namesOf[0].Row2[0].residentUSCandaMexico[0]" => "Y",
                            "form1[0].page1[0].namesOf[0].Row2[0].fullTimeStudent[0]" => "Y",
                            "form1[0].page1[0].namesOf[0].Row2[0].totallyPermanentlyDisabled[0]" => "N",
                            "form1[0].page1[0].namesOf[0].Row2[0].issuedIPPIN[0]" => "N",
                            # dependent 3
                            "form1[0].page1[0].namesOf[0].Row3[0].nameFirstLast[0]" => "Penny Pony",
                            "form1[0].page1[0].namesOf[0].Row3[0].dateOfBirth[0]" => "10/15/2010",
                            "form1[0].page1[0].namesOf[0].Row3[0].relationshipToYou[0]" => "Progeny",
                            "form1[0].page1[0].namesOf[0].Row3[0].monthsLivedHome[0]" => "12",
                            "form1[0].page1[0].namesOf[0].Row3[0].singleMarried[0]" => "S",
                            "form1[0].page1[0].namesOf[0].Row3[0].usCitizen[0]" => "N",
                            "form1[0].page1[0].namesOf[0].Row3[0].residentUSCandaMexico[0]" => "Y",
                            "form1[0].page1[0].namesOf[0].Row3[0].fullTimeStudent[0]" => "N",
                            "form1[0].page1[0].namesOf[0].Row3[0].totallyPermanentlyDisabled[0]" => "Y",
                            "form1[0].page1[0].namesOf[0].Row3[0].issuedIPPIN[0]" => "",
                            )
      end

      it 'fills out certified volunteer section of the dependent info on page 1 correctly' do
        output_file = intake_pdf.output_file
        result = non_preparer_fields(output_file.path)
        expect(result).to include(
                            "form1[0].page1[0].anyoneElseClaim[0].otherClaimYes[0]" => "",
                            "form1[0].page1[0].anyoneElseClaim[0].otherClaimNo[0]" => "1",
                            # dependent 1
                            "form1[0].page1[0].namesOf[0].Row1[0].qualifyingChildDependent[0]" => "Yes",
                            "form1[0].page1[0].namesOf[0].Row1[0].ownSupport[0]" => "No",
                            "form1[0].page1[0].namesOf[0].Row1[0].lessThanIncome[0]" => "Yes",
                            "form1[0].page1[0].namesOf[0].Row1[0].supportForPerson[0]" => "Yes",
                            "form1[0].page1[0].namesOf[0].Row1[0].costMaintainingHome[0]" => "N/A",
                            # dependent 2
                            "form1[0].page1[0].namesOf[0].Row2[0].qualifyingChildDependent[0]" => "No",
                            "form1[0].page1[0].namesOf[0].Row2[0].ownSupport[0]" => "N/A",
                            "form1[0].page1[0].namesOf[0].Row2[0].lessThanIncome[0]" => "Yes",
                            "form1[0].page1[0].namesOf[0].Row2[0].supportForPerson[0]" => "N/A",
                            "form1[0].page1[0].namesOf[0].Row2[0].costMaintainingHome[0]" => "Yes",
                            # dependent 3
                            "form1[0].page1[0].namesOf[0].Row3[0].qualifyingChildDependent[0]" => "No",
                            "form1[0].page1[0].namesOf[0].Row3[0].ownSupport[0]" => "Yes",
                            "form1[0].page1[0].namesOf[0].Row3[0].lessThanIncome[0]" => "N/A",
                            "form1[0].page1[0].namesOf[0].Row3[0].supportForPerson[0]" => "N/A",
                            "form1[0].page1[0].namesOf[0].Row3[0].costMaintainingHome[0]" => "Yes",
                            )
      end

      # TODO reenable for TY2024
      xit "can successfully write everything that comes out of #hash_for_pdf to the PDF" do
        expect(intake_pdf.hash_for_pdf.length).to be > 100 # sanity check
        form_fields = PdfForms.new.get_fields(intake_pdf.output_file)

        all_fields_in_pdf = form_fields.map(&:name)
        expect(all_fields_in_pdf).to match_array(intake_pdf.hash_for_pdf.keys)
      end

      it 'fills out written language preference and voter information sections correctly' do
        output_file = intake_pdf.output_file
        result = non_preparer_fields(output_file.path)
        expect(result).to include(
                            "form1[0].page1[0].writtenCommunicationLanguage[0].otherLanguageNo[0]" => '',
                            "form1[0].page1[0].writtenCommunicationLanguage[0].otherLanguageYou[0]" => '1',
                            "form1[0].page1[0].writtenCommunicationLanguage[0].whatLanguage[0]" => "Russian",
                            "form1[0].page1[0].howToVote[0].voteInformationYes[0]" => "",
                            "form1[0].page1[0].howToVote[0].voteInformationNo[0]" => "1",
                          )
      end

      # TODO reenable for TY2024
      xit "fills out answers from the DB into the pdf" do
        output_file = intake_pdf.output_file
        result = non_preparer_fields(output_file.path)
        expect(result).to include(
                            "form1[0].page1[0].yourFirstName[0]" => "Hoofie",
                            "form1[0].page1[0].yourMiddleInitial[0]" => "",
                            "form1[0].page1[0].yourLastName[0]" => "Heifer",
                            "form1[0].page1[0].telephoneNumber[0]" => "(415) 816-1286",
                            "form1[0].page1[0].q1AreYouA[0].optionYes[0]" => "Off",
                            "form1[0].page1[0].q1AreYouA[0].optionNo[0]" => "1",
                            "form1[0].page1[0].q2SpouseFirstName[0]" => "Hattie",
                            "form1[0].page1[0].q2SpouseMiddleInitial[0]" => "",
                            "form1[0].page1[0].q2SpouseLastName[0]" => "Heifer",
                            "form1[0].page1[0].q2TelephoneNumber[0]" => "",
                            "form1[0].page1[0].q2IsYourSpouse[0].optionYes[0]" => "1",
                            "form1[0].page1[0].q2IsYourSpouse[0].optionNo[0]" => "Off",
                            "form1[0].page1[0].q3MailingAddress[0]" => "789 Garden Green Ln",
                            "form1[0].page1[0].p3ApartmentNumber[0]" => "",
                            "form1[0].page1[0].q3City[0]" => "Gardenia",
                            "form1[0].page1[0].q3State[0]" => "NJ",
                            "form1[0].page1[0].q3ZIPCode[0]" => "08052",
                            "form1[0].page1[0].q4YourDateBirth[0]" => "4/19/1961",
                            "form1[0].page1[0].q5YourJobTitle[0]" => "",
                            "form1[0].page1[0].q6AreYou[0].q6aFullTimeStudent[0].optionYes[0]" => "Off",
                            "form1[0].page1[0].q6AreYou[0].q6aFullTimeStudent[0].optionNo[0]" => "1",
                            "form1[0].page1[0].q6AreYou[0].q6bTotallyPermanentlyDisabled[0].optionYes[0]" =>
                              "1",
                            "form1[0].page1[0].q6AreYou[0].q6bTotallyPermanentlyDisabled[0].optionNo[0]" =>
                              "Off",
                            "form1[0].page1[0].q6AreYou[0].q6cLegallyBlind[0].optionYes[0]" => "Off",
                            "form1[0].page1[0].q6AreYou[0].q6cLegallyBlind[0].optionNo[0]" => "1",
                            "form1[0].page1[0].q7SpouseDateBirth[0]" => "11/1/1959",
                            "form1[0].page1[0].q8SpouseJobTitle[0]" => "",
                            "form1[0].page1[0].q9IsYourSpouse[0].q9aFullTimeStudent[0].optionYes[0]" => "1",
                            "form1[0].page1[0].q9IsYourSpouse[0].q9aFullTimeStudent[0].optionNo[0]" =>
                              "Off",
                            "form1[0].page1[0].q9IsYourSpouse[0].q9bTotallyPermanentlyDisabled[0].optionYes[0]" =>
                              "Off",
                            "form1[0].page1[0].q9IsYourSpouse[0].q9bTotallyPermanentlyDisabled[0].optionNo[0]" =>
                              "1",
                            "form1[0].page1[0].q9IsYourSpouse[0].q9cLegallyBlind[0].optionYes[0]" => "Off",
                            "form1[0].page1[0].q9IsYourSpouse[0].q9cLegallyBlind[0].optionNo[0]" => "1",
                            "form1[0].page1[0].q10CanAnyoneClaim[0].optionYes[0]" => "Off",
                            "form1[0].page1[0].q10CanAnyoneClaim[0].optionNo[0]" => "1",
                            "form1[0].page1[0].q10CanAnyoneClaim[0].optionUnsure[0]" => "Off",
                            "form1[0].page1[0].q11HaveYouOr[0].optionYes[0]" => "Off",
                            "form1[0].page1[0].q11HaveYouOr[0].optionNo[0]" => "1",
                            "form1[0].page1[0].q12EmailAddress[0]" => "hoofie@heifer.horse",
                            "form1[0].page1[0].q1AsOfDecember[0].neverMarried[0]" => "",
                            "form1[0].page1[0].q1AsOfDecember[0].married[0]" => "1",
                            "form1[0].page1[0].q1AsOfDecember[0].q1aGetMarried[0].optionYes[0]" => "Off",
                            "form1[0].page1[0].q1AsOfDecember[0].q1aGetMarried[0].optionNo[0]" => "Off",
                            "form1[0].page1[0].q1AsOfDecember[0].q1bLiveWith[0].optionYes[0]" => "1",
                            "form1[0].page1[0].q1AsOfDecember[0].q1bLiveWith[0].optionNo[0]" => "Off",
                            "form1[0].page1[0].q1AsOfDecember[0].divorced[0]" => "",
                            "form1[0].page1[0].q1AsOfDecember[0].DateOfFinal[0]" => "2015",
                            "form1[0].page1[0].q1AsOfDecember[0].legallySeparated[0]" => "",
                            "form1[0].page1[0].q1AsOfDecember[0].DateOfSeparate[0]" => "2016",
                            "form1[0].page1[0].q1AsOfDecember[0].widowed[0]" => "",
                            "form1[0].page1[0].q1AsOfDecember[0].YearOfDeath[0]" => "2017",
                            "form1[0].page1[0].additionalSpace[0].additionalSpace[0]" => "", # getting back "OFF"
                            "form1[0].page1[0].namesOf[0].Row1[0].USCitizen[0]" => "Y",
                            "form1[0].page1[0].namesOf[0].Row1[0].claimedBySomeone[0]" => "",
                            "form1[0].page1[0].namesOf[0].Row1[0].dateBirth[0]" => "3/2/2005",
                            "form1[0].page1[0].namesOf[0].Row1[0].disabled[0]" => "N",
                            "form1[0].page1[0].namesOf[0].Row1[0].hadIncomeLess[0]" => "",
                            "form1[0].page1[0].namesOf[0].Row1[0].maintainedHome[0]" => "",
                            "form1[0].page1[0].namesOf[0].Row1[0].months[0]" => "12",
                            "form1[0].page1[0].namesOf[0].Row1[0].name[0]" => "Percy Pony",
                            "form1[0].page1[0].namesOf[0].Row1[0].providedMoreThen[0]" => "",
                            "form1[0].page1[0].namesOf[0].Row1[0].relationship[0]" => "Child",
                            "form1[0].page1[0].namesOf[0].Row1[0].residentOf[0]" => "Y",
                            "form1[0].page1[0].namesOf[0].Row1[0].singleMarried[0]" => "S",
                            "form1[0].page1[0].namesOf[0].Row1[0].student[0]" => "N",
                            "form1[0].page1[0].namesOf[0].Row1[0].supportPerson[0]" => "",
                            "form1[0].page1[0].namesOf[0].Row2[0].USCitizen[0]" => "Y",
                            "form1[0].page1[0].namesOf[0].Row2[0].claimedBySomeone[0]" => "",
                            "form1[0].page1[0].namesOf[0].Row2[0].dateBirth[0]" => "12/10/2001",
                            "form1[0].page1[0].namesOf[0].Row2[0].disabled[0]" => "N",
                            "form1[0].page1[0].namesOf[0].Row2[0].hadIncomeLess[0]" => "",
                            "form1[0].page1[0].namesOf[0].Row2[0].maintainedHome[0]" => "",
                            "form1[0].page1[0].namesOf[0].Row2[0].months[0]" => "4",
                            "form1[0].page1[0].namesOf[0].Row2[0].name[0]" => "Parker Pony",
                            "form1[0].page1[0].namesOf[0].Row2[0].providedMoreThen[0]" => "",
                            "form1[0].page1[0].namesOf[0].Row2[0].relationship[0]" => "Some kid at my house",
                            "form1[0].page1[0].namesOf[0].Row2[0].residentOf[0]" => "Y",
                            "form1[0].page1[0].namesOf[0].Row2[0].singleMarried[0]" => "M",
                            "form1[0].page1[0].namesOf[0].Row2[0].student[0]" => "Y",
                            "form1[0].page1[0].namesOf[0].Row2[0].supportPerson[0]" => "",
                            "form1[0].page1[0].namesOf[0].Row3[0].USCitizen[0]" => "N",
                            "form1[0].page1[0].namesOf[0].Row3[0].claimedBySomeone[0]" => "",
                            "form1[0].page1[0].namesOf[0].Row3[0].dateBirth[0]" => "10/15/2010",
                            "form1[0].page1[0].namesOf[0].Row3[0].disabled[0]" => "Y",
                            "form1[0].page1[0].namesOf[0].Row3[0].hadIncomeLess[0]" => "",
                            "form1[0].page1[0].namesOf[0].Row3[0].maintainedHome[0]" => "",
                            "form1[0].page1[0].namesOf[0].Row3[0].months[0]" => "12",
                            "form1[0].page1[0].namesOf[0].Row3[0].name[0]" => "Penny Pony",
                            "form1[0].page1[0].namesOf[0].Row3[0].providedMoreThen[0]" => "",
                            "form1[0].page1[0].namesOf[0].Row3[0].relationship[0]" => "Progeny",
                            "form1[0].page1[0].namesOf[0].Row3[0].residentOf[0]" => "Y",
                            "form1[0].page1[0].namesOf[0].Row3[0].singleMarried[0]" => "S",
                            "form1[0].page1[0].namesOf[0].Row3[0].student[0]" => "N",
                            "form1[0].page1[0].namesOf[0].Row3[0].supportPerson[0]" => "",
                            "form1[0].page2[0].Part3[0].q1WagesOrSalary[0].optionYes[0]" => "1",
                            "form1[0].page2[0].Part3[0].q1WagesOrSalary[0].optionNo[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q1WagesOrSalary[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q1WagesOrSalary[0].NumberOfJobs[0]" => "5",
                            "form1[0].page2[0].Part3[0].q2TipIncome[0].optionYes[0]" => "1",
                            "form1[0].page2[0].Part3[0].q2TipIncome[0].optionNo[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q2TipIncome[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q3Scholarships[0].optionYes[0]" => "1",
                            "form1[0].page2[0].Part3[0].q3Scholarships[0].optionNo[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q3Scholarships[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q4InterestDividendsFrom[0].optionYes[0]" => "1",
                            "form1[0].page2[0].Part3[0].q4InterestDividendsFrom[0].optionNo[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q4InterestDividendsFrom[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q5RefundOfState[0].optionYes[0]" => "1",
                            "form1[0].page2[0].Part3[0].q5RefundOfState[0].optionNo[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q5RefundOfState[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q6AlimonyIncome[0].optionYes[0]" => "1",
                            "form1[0].page2[0].Part3[0].q6AlimonyIncome[0].optionNo[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q6AlimonyIncome[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q7SelfEmploymentIncome[0].optionYes[0]" => "1",
                            "form1[0].page2[0].Part3[0].q7SelfEmploymentIncome[0].optionNo[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q7SelfEmploymentIncome[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q8CashCheckPayments[0].optionYes[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q8CashCheckPayments[0].optionNo[0]" => "1",
                            "form1[0].page2[0].Part3[0].q8CashCheckPayments[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q9Income[0].optionYes[0]" => "1",
                            "form1[0].page2[0].Part3[0].q9Income[0].optionNo[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q9Income[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q10DisabilityIncome[0].optionYes[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q10DisabilityIncome[0].optionNo[0]" => "1",
                            "form1[0].page2[0].Part3[0].q10DisabilityIncome[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q11RetirementIncome[0].optionYes[0]" => "1",
                            "form1[0].page2[0].Part3[0].q11RetirementIncome[0].optionNo[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q11RetirementIncome[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q12UnemploymentCompensation[0].optionYes[0]" => "1",
                            "form1[0].page2[0].Part3[0].q12UnemploymentCompensation[0].optionNo[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q12UnemploymentCompensation[0].optionUnsure[0]" =>
                              "Off",
                            "form1[0].page2[0].Part3[0].q13SocialSecurityOr[0].optionYes[0]" => "1",
                            "form1[0].page2[0].Part3[0].q13SocialSecurityOr[0].optionNo[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q13SocialSecurityOr[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q14IncomeOrLoss[0].optionYes[0]" => "1",
                            "form1[0].page2[0].Part3[0].q14IncomeOrLoss[0].optionNo[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q14IncomeOrLoss[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q15OtherIncome[0].optionYes[0]" => "1",
                            "form1[0].page2[0].Part3[0].q15OtherIncome[0].optionNo[0]" => "Off",
                            "form1[0].page2[0].Part3[0].q15OtherIncome[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part4[0].q1Alimony[0].optionYes[0]" => "1",
                            "form1[0].page2[0].Part4[0].q1Alimony[0].optionNo[0]" => "Off",
                            "form1[0].page2[0].Part4[0].q1Alimony[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part4[0].q1Alimony[0].IfYes[0].optionYes[0]" => "1",
                            "form1[0].page2[0].Part4[0].q1Alimony[0].IfYes[0].optionNo[0]" => "Off",
                            "form1[0].page2[0].Part4[0].q2Contributions[0].optionYes[0]" => "Off",
                            "form1[0].page2[0].Part4[0].q2Contributions[0].optionNo[0]" => "Off",
                            "form1[0].page2[0].Part4[0].q2Contributions[0].optionUnsure[0]" => "1",
                            "form1[0].page2[0].Part4[0].q2Contributions[0].IRA[0]" => "",
                            "form1[0].page2[0].Part4[0].q2Contributions[0].RothIRA[0]" => "1",
                            "form1[0].page2[0].Part4[0].q2Contributions[0]._401K[0]" => "1",
                            "form1[0].page2[0].Part4[0].q2Contributions[0].Other[0]" => "",
                            "form1[0].page2[0].Part4[0].q3PostSecondary[0].optionYes[0]" => "1",
                            "form1[0].page2[0].Part4[0].q3PostSecondary[0].optionNo[0]" => "Off",
                            "form1[0].page2[0].Part4[0].q3PostSecondary[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part4[0].q4Deductions[0].optionYes[0]" => "1",
                            "form1[0].page2[0].Part4[0].q4Deductions[0].optionNo[0]" => "Off",
                            "form1[0].page2[0].Part4[0].q4Deductions[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part4[0].q4Deductions[0].medical[0]" => "1",
                            "form1[0].page2[0].Part4[0].q4Deductions[0].mortgage[0]" => "",
                            "form1[0].page2[0].Part4[0].q4Deductions[0].taxes[0]" => "1",
                            "form1[0].page2[0].Part4[0].q4Deductions[0].charitable[0]" => "",
                            "form1[0].page2[0].Part4[0].q5ChildOrDependent[0].optionYes[0]" => "Off",
                            "form1[0].page2[0].Part4[0].q5ChildOrDependent[0].optionNo[0]" => "Off",
                            "form1[0].page2[0].Part4[0].q5ChildOrDependent[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part4[0].q6ForSuppliesUsed[0].optionYes[0]" => "1",
                            "form1[0].page2[0].Part4[0].q6ForSuppliesUsed[0].optionNo[0]" => "Off",
                            "form1[0].page2[0].Part4[0].q6ForSuppliesUsed[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part4[0].q7ExpensesRelatedTo[0].optionYes[0]" => "Off",
                            "form1[0].page2[0].Part4[0].q7ExpensesRelatedTo[0].optionNo[0]" => "1",
                            "form1[0].page2[0].Part4[0].q7ExpensesRelatedTo[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part4[0].q8StudentLoanInterest[0].optionYes[0]" => "1",
                            "form1[0].page2[0].Part4[0].q8StudentLoanInterest[0].optionNo[0]" => "Off",
                            "form1[0].page2[0].Part4[0].q8StudentLoanInterest[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part5[0].q1HaveAHealth[0].optionYes[0]" => "Off",
                            "form1[0].page2[0].Part5[0].q1HaveAHealth[0].optionNo[0]" => "1",
                            "form1[0].page2[0].Part5[0].q1HaveAHealth[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part5[0].q2HaveDebtFrom[0].optionYes[0]" => "1",
                            "form1[0].page2[0].Part5[0].q2HaveDebtFrom[0].optionNo[0]" => "Off",
                            "form1[0].page2[0].Part5[0].q2HaveDebtFrom[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part5[0].q3AdoptAChild[0].optionYes[0]" => "Off",
                            "form1[0].page2[0].Part5[0].q3AdoptAChild[0].optionNo[0]" => "1",
                            "form1[0].page2[0].Part5[0].q3AdoptAChild[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part5[0].q4HaveEarnedIncome[0].optionYes[0]" => "1",
                            "form1[0].page2[0].Part5[0].q4HaveEarnedIncome[0].optionNo[0]" => "Off",
                            "form1[0].page2[0].Part5[0].q4HaveEarnedIncome[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part5[0].q4HaveEarnedIncome[0].WhichTaxYear[0]" => "2018",
                            "form1[0].page2[0].Part5[0].q5PurchaseAndInstall[0].optionYes[0]" => "Off",
                            "form1[0].page2[0].Part5[0].q5PurchaseAndInstall[0].optionNo[0]" => "Off",
                            "form1[0].page2[0].Part5[0].q5PurchaseAndInstall[0].optionUnsure[0]" => "1",
                            "form1[0].page2[0].Part5[0].q6ReceiveTheFirst[0].optionYes[0]" => "Off",
                            "form1[0].page2[0].Part5[0].q6ReceiveTheFirst[0].optionNo[0]" => "1",
                            "form1[0].page2[0].Part5[0].q6ReceiveTheFirst[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part5[0].q7MakeEstimatedTax[0].optionYes[0]" => "Off",
                            "form1[0].page2[0].Part5[0].q7MakeEstimatedTax[0].optionNo[0]" => "Off",
                            "form1[0].page2[0].Part5[0].q7MakeEstimatedTax[0].optionUnsure[0]" => "1",
                            "form1[0].page2[0].Part5[0].q7MakeEstimatedTax[0].HowMuch[0]" => "0.0",
                            "form1[0].page2[0].Part5[0].q8FileAFederal[0].optionYes[0]" => "Off",
                            "form1[0].page2[0].Part5[0].q8FileAFederal[0].optionNo[0]" => "1",
                            "form1[0].page2[0].Part5[0].q8FileAFederal[0].optionUnsure[0]" => "Off",
                            "form1[0].page2[0].Part5[0].q9HaveHealth[0].optionYes[0]" => "1",
                            "form1[0].page2[0].Part5[0].q9HaveHealth[0].optionNo[0]" => "Off",
                            "form1[0].page2[0].Part5[0].q9HaveHealth[0].optionUnsure[0]" => "Off",
                            "form1[0].page3[0].q1[0].optionYes[0]" => "1",
                            "form1[0].page3[0].q1[0].optionNo[0]" => "Off",
                            "form1[0].page3[0].q1[0].WhichLanguage[0]" => "Greek",
                            "form1[0].page3[0].q2[0].you[0]" => "1",
                            "form1[0].page3[0].q2[0].spouse[0]" => "Off",
                            "form1[0].page3[0].q3[0].DirectDeposit[0].optionYes[0]" => "1",
                            "form1[0].page3[0].q3[0].DirectDeposit[0].optionNo[0]" => "Off",
                            "form1[0].page3[0].q3[0].SavingsBonds[0].optionYes[0]" => "1",
                            "form1[0].page3[0].q3[0].SavingsBonds[0].optionNo[0]" => "Off",
                            "form1[0].page3[0].q3[0].DifferentAccounts[0].optionYes[0]" => "Off",
                            "form1[0].page3[0].q3[0].DifferentAccounts[0].optionNo[0]" => "1",
                            "form1[0].page3[0].q4[0].optionYes[0]" => "Off",
                            "form1[0].page3[0].q4[0].optionNo[0]" => "1",
                            "form1[0].page3[0].q5[0].optionYes[0]" => "1",
                            "form1[0].page3[0].q5[0].optionNo[0]" => "Off",
                            "form1[0].page3[0].q5[0].IfYesWhere[0]" => "Athens",
                            "form1[0].page3[0].q6[0].yes[0]" => "Off",
                            "form1[0].page3[0].q6[0].optionNo[0]" => "1",
                            "form1[0].page1[0].howToVote[0].voteInformationYes[0]" => "",
                            "form1[0].page1[0].howToVote[0].voteInformationNo[0]" => "1",
                            "form1[0].page3[0].q8[0].veryWell[0]" => "",
                            "form1[0].page3[0].q8[0].well[0]" => "1",
                            "form1[0].page3[0].q8[0].notWell[0]" => "",
                            "form1[0].page3[0].q8[0].notAtAll[0]" => "",
                            "form1[0].page3[0].q8[0].notAnswer[0]" => "",
                            "form1[0].page3[0].q9[0].veryWell[0]" => "",
                            "form1[0].page3[0].q9[0].well[0]" => "",
                            "form1[0].page3[0].q9[0].notWell[0]" => "1",
                            "form1[0].page3[0].q9[0].notAtAll[0]" => "",
                            "form1[0].page3[0].q9[0].notAnswer[0]" => "",
                            "form1[0].page3[0].q10[0].optionYes[0]" => "1",
                            "form1[0].page3[0].q10[0].optionNo[0]" => "",
                            "form1[0].page3[0].q10[0].notAnswer[0]" => "",
                            "form1[0].page3[0].q11[0].optionYes[0]" => "",
                            "form1[0].page3[0].q11[0].optionNo[0]" => "1",
                            "form1[0].page3[0].q11[0].notAnswer[0]" => "",
                            "form1[0].page3[0].q12[0].americanIndian[0]" => "",
                            "form1[0].page3[0].q12[0].asian[0]" => "",
                            "form1[0].page3[0].q12[0].blackAfrican[0]" => "",
                            "form1[0].page3[0].q12[0].nativeHawaiian[0]" => "1",
                            "form1[0].page3[0].q12[0].white[0]" => "1",
                            "form1[0].page3[0].q12[0].notAnswer[0]" => "",
                            "form1[0].page3[0].q13[0].americanIndian[0]" => "1",
                            "form1[0].page3[0].q13[0].asian[0]" => "",
                            "form1[0].page3[0].q13[0].blackAfrican[0]" => "",
                            "form1[0].page3[0].q13[0].nativeHawaiian[0]" => "",
                            "form1[0].page3[0].q13[0].white[0]" => "",
                            "form1[0].page3[0].q13[0].notAnswer[0]" => "",
                            "form1[0].page3[0].q13[0].noSpouse[0]" => "",
                            "form1[0].page3[0].q14[0].hispanicLatino[0]" => "",
                            "form1[0].page3[0].q14[0].notHispanicLatino[0]" => "1",
                            "form1[0].page3[0].q14[0].notAnswer[0]" => "",
                            "form1[0].page3[0].q15[0].hispanicLatino[0]" => "",
                            "form1[0].page3[0].q15[0].notHispanicLatino[0]" => "1",
                            "form1[0].page3[0].q15[0].notAnswer[0]" => "",
                            "form1[0].page3[0].q15[0].noSpouse[0]" => "",
                            "form1[0].page3[0].AdditionalComments[0].AdditionalComments[1]" =>
                              "if there is another gnome living in my garden but only i have an income, does that make me head of household? Also here are some additional notes.\rOther income types: garden gnoming",
                            "form1[0].page4[0].primaryTaxpayer[0]" => "Hoofie Heifer",
                            "form1[0].page4[0].primarydateSigned[0]" => "1/1/2024",
                            "form1[0].page4[0].secondaryTaxpayer[0]" => "Hattie Heifer",
                            "form1[0].page4[0].secondaryDateSigned[0]" => "1/1/2024"
                          )
      end

      # TODO reenable for TY2024
      xdescribe "gated questions" do
        it "uses the actual value from the DB for the question answer when the gated question(s) is 'yes'" do
          intake.update(
            ever_owned_home: "yes",
            wants_to_itemize: "no",
            received_homebuyer_credit: "no",
            paid_mortgage_interest: "unfilled"
          )

          output_file = intake_pdf.output_file
          result = non_preparer_fields(output_file.path)
          expect(result).to include(
            "form1[0].page2[0].Part5[0].q6ReceiveTheFirst[0].optionYes[0]" => "Off",
            "form1[0].page2[0].Part5[0].q6ReceiveTheFirst[0].optionNo[0]" => "1",
            "form1[0].page2[0].Part5[0].q6ReceiveTheFirst[0].optionUnsure[0]" => "Off",
            "form1[0].page2[0].Part4[0].q4Deductions[0].mortgage[0]" => "",
          )

          # 1. update received_homebuyer_credit answer and see that it is used because the gating question is 'yes'
          # 2. update wants_to_itemize and paid_mortgage_interest to 'yes' and see that the answer to paid_mortgage_interest is
          # used because both gating questions are now 'yes'
          intake.update(
            ever_owned_home: "yes",
            wants_to_itemize: "yes",
            received_homebuyer_credit: "yes",
            paid_mortgage_interest: "yes"
          )
          output_file = intake_pdf.output_file
          result = non_preparer_fields(output_file.path)
          expect(result).to include(
            "form1[0].page2[0].Part5[0].q6ReceiveTheFirst[0].optionYes[0]" => "1",
            "form1[0].page2[0].Part5[0].q6ReceiveTheFirst[0].optionNo[0]" => "Off",
            "form1[0].page2[0].Part5[0].q6ReceiveTheFirst[0].optionUnsure[0]" => "Off",
            "form1[0].page2[0].Part4[0].q4Deductions[0].mortgage[0]" => "1",
          )
        end
      end

      describe 'Page 2 right-hand side: certified volunteer Income' do
        it 'fills all the pdf fields correctly' do
          intake.update(
            cv_w2s_cb: 'yes',
            cv_w2s_count: 3,
            cv_had_tips_cb: 'yes',
            cv_1099r_cb: 'yes',
            cv_1099r_count: 2,
            cv_1099r_charitable_dist_cb: 'yes',
            cv_1099r_charitable_dist_amt: 12_500,
            cv_disability_benefits_1099r_or_w2_cb: 'yes',
            cv_disability_benefits_1099r_or_w2_count: 4,
            cv_ssa1099_rrb1099_cb: 'yes',
            cv_ssa1099_rrb1099_count: 2,
            cv_1099g_cb: 'yes',
            cv_1099g_count: '3',
            cv_local_tax_refund_cb: 'yes',
            cv_local_tax_refund_amt: 1500,
            cv_itemized_last_year_cb: 'yes',
            cv_1099int_cb: 'yes',
            cv_1099int_count: 3,
            cv_1099div_cb: 'yes',
            cv_1099div_count: 2,
            cv_1099b_cb: 'yes',
            cv_1099b_count: 5,
            cv_capital_loss_carryover_cb: 'yes',
            cv_alimony_income_cb: 'yes',
            cv_alimony_income_amt: 1000,
            cv_alimony_excluded_from_income_cb: 'yes',
            cv_rental_income_cb: 'yes',
            cv_rental_expense_cb: 'yes',
            cv_rental_expense_amt: 1236,
            cv_w2g_or_other_gambling_winnings_cb: 'yes',
            cv_w2g_or_other_gambling_winnings_count: 4,
            cv_schedule_c_cb: 'yes',
            cv_1099misc_cb: 'yes',
            cv_1099misc_count: 5,
            cv_1099nec_cb: 'yes',
            cv_1099nec_count: 4,
            cv_1099k_cb: 'yes',
            cv_1099k_count: 1,
            cv_other_income_reported_elsewhere_cb: 'yes',
            cv_schedule_c_expenses_cb: 'yes',
            cv_schedule_c_expenses_amt: 768,
            cv_other_income_cb: 'yes',
            cv_p2_notes_comments: 'twinkle twinkle little star'

          )

          output_file = intake_pdf.output_file
          result = non_preparer_fields(output_file.path)
          expect(result).to include(
                              'form1[0].page2[0].incomeIncluded[0].formW2s[0]' => '1',
                              "form1[0].page2[0].incomeIncluded[0].formW2sNumber[0]" => "3",
                              "form1[0].page2[0].incomeIncluded[0].tipsBasicReported[0]" => '1',
                              "form1[0].page2[0].incomeIncluded[0].form1099R[0]" => "1",
                              "form1[0].page2[0].incomeIncluded[0].form1099RNumber[0]" => "2", # cv_1099r_count
                              "form1[0].page2[0].incomeIncluded[0].qualifiedCharitableDistribution[0]" => '1',
                              "form1[0].page2[0].incomeIncluded[0].qualifiedCharitableAmount[0]" => "12500.0",
                              "form1[0].page2[0].incomeIncluded[0].disabilityBenefits[0]" => '1',
                              "form1[0].page2[0].incomeIncluded[0].disabilityBenefitsNumber[0]" => "4",
                              "form1[0].page2[0].incomeIncluded[0].ssaRRB1099[0]" => '1',
                              "form1[0].page2[0].incomeIncluded[0].ssaRRB1099Number[0]" => '2',
                              "form1[0].page2[0].incomeIncluded[0].form1099G[0]" => '1',
                              "form1[0].page2[0].incomeIncluded[0].form1099GNumber[0]" => '3', # cv_1099g_count
                              "form1[0].page2[0].incomeIncluded[0].refund[0].refund[0]" => '1',
                              "form1[0].page2[0].incomeIncluded[0].refund[0].refundAmount[0]" => '1500.0',
                              "form1[0].page2[0].incomeIncluded[0].itemizedLastYear[0].itemizedLastYear[0]" => '1', # cv_itemized_last_year_cb
                              "form1[0].page2[0].incomeIncluded[0].itemizedLastYear[0].itemizedYes[0]" => '1',
                              "form1[0].page2[0].incomeIncluded[0].itemizedLastYear[0].itemizedNo[0]" => '',
                              "form1[0].page2[0].incomeIncluded[0].form1099INTDIV[0].form1099INT[0]" => '1',
                              "form1[0].page2[0].incomeIncluded[0].form1099INTDIV[0].form1099INTNumber[0]" => '3',
                              "form1[0].page2[0].incomeIncluded[0].form1099INTDIV[0].form1099DIV[0]" => '1',
                              "form1[0].page2[0].incomeIncluded[0].form1099INTDIV[0].form1099DIVNumber[0]" => '2',
                              "form1[0].page2[0].incomeIncluded[0].form1099B[0].form1099B[0]" => '1', # cv_1099b_cb
                              "form1[0].page2[0].incomeIncluded[0].form1099B[0].form1099BNumber[0]" => '5',
                              "form1[0].page2[0].incomeIncluded[0].form1099B[0].capitalLossCarryover[0].capitalLossCarryover[0]" => '1',
                              "form1[0].page2[0].incomeIncluded[0].form1099B[0].capitalLossCarryover[0].capitalLossCarryoverYes[0]" => '1',
                              "form1[0].page2[0].incomeIncluded[0].form1099B[0].capitalLossCarryover[0].capitalLossCarryoverNo[0]" => '',
                              "form1[0].page2[0].incomeIncluded[0].alimonyIncome[0].alimonyIncome[0]" => '1',
                              "form1[0].page2[0].incomeIncluded[0].alimonyIncome[0].alimonyAmount[0]" => '1000.0',
                              "form1[0].page2[0].incomeIncluded[0].alimonyIncome[0].excludedYes[0]" => '1',
                              "form1[0].page2[0].incomeIncluded[0].alimonyIncome[0].excludedNo[0]" => '',
                              "form1[0].page2[0].incomeIncluded[0].rentalIncome[0].rentalIncome[0]" => '1', # cv_rental_income_cb
                              "form1[0].page2[0].incomeIncluded[0].rentalIncome[0].rentalExpense[0]" => '1',
                              "form1[0].page2[0].incomeIncluded[0].rentalIncome[0].rentalExpenseAmount[0]" => '1236.0',
                              "form1[0].page2[0].incomeIncluded[0].formW2G[0].formW2G[0]" => '1',
                              "form1[0].page2[0].incomeIncluded[0].formW2G[0].formW2GNumber[0]" => '4',
                              "form1[0].page2[0].incomeIncluded[0].scheduleC[0]" => '1',
                              "form1[0].page2[0].incomeIncluded[0].form1099MISC[0]" => '1',
                              "form1[0].page2[0].incomeIncluded[0].form1099MISCNumber[0]" => '5',
                              "form1[0].page2[0].incomeIncluded[0].form1099NEC[0]" => '1',
                              "form1[0].page2[0].incomeIncluded[0].form1099NECNumber[0]" => '4',
                              "form1[0].page2[0].incomeIncluded[0].form1099K[0]" => '1', # cv_1099k_cb
                              "form1[0].page2[0].incomeIncluded[0].form1099KNumber[0]" => '1',
                              "form1[0].page2[0].incomeIncluded[0].otherInomceReported[0]" => '1',
                              "form1[0].page2[0].incomeIncluded[0].scheduleCExpenses[0]" => '1',
                              "form1[0].page2[0].incomeIncluded[0].scheduleCExpensesAmount[0]" => '768.0',
                              "form1[0].page2[0].incomeIncluded[0].otherIncome[0].otherIncome[0]" => '1',
                              "form1[0].page2[0].IncomeIncludedComment[0].IncomeIncludedComments[0]" => 'twinkle twinkle little star',
                            )
        end
      end

      describe "you_and_spouse_info" do
        it "should contain the correct information" do
          expect(intake_pdf.you_and_spouse_info).to include({
                                                              # You
                                                              "form1[0].page1[0].yourFirstName[0]" => "Hoofie",
                                                              "form1[0].page1[0].yourMiddleInitial[0]" => nil,
                                                              "form1[0].page1[0].yourLastName[0]" => "Heifer",
                                                              "form1[0].page1[0].yourTelephoneNumber[0]" => "(415) 816-1286",
                                                              "form1[0].page1[0].yourDateOfBirth[0]" => "4/19/1961",
                                                              "form1[0].page1[0].yourJobTitle[0]" => nil,

                                                              # Spouse
                                                              "form1[0].page1[0].youSpouseWereIn[0].column2[0].totallyPermanentlyDisabled[0].disabledYou[0]" => "1",
                                                              "form1[0].page1[0].youSpouseWereIn[0].column2[0].legallyBlind[0].legallyBlindNo[0]" => "1",
                                                              "form1[0].page1[0].spousesFirstName[0]" => 'Hattie',
                                                              "form1[0].page1[0].spousesMiddleInitial[0]" => nil,
                                                              "form1[0].page1[0].spousesLastName[0]" => 'Heifer',
                                                              "form1[0].page1[0].spousesTelephoneNumber[0]" => nil,
                                                              "form1[0].page1[0].spousesDateOfBirth[0]" => "11/1/1959",
                                                              "form1[0].page1[0].spousesJobTitle[0]" => nil,
                                                            })
        end
      end

      describe 'page 3 (expenses) gray questions on right-hand side' do
        describe 'section 1 on 3' do
          it 'looks good when all choices are no and fields are nil' do
            intake.update(
              cv_1098_cb: 'no',
              cv_1098_count: nil,
              cv_med_expense_standard_deduction_cb: 'no',
              cv_med_expense_itemized_deduction_cb: 'no',
              cv_14c_page_3_notes_part_1: nil
            )

            output_file = intake_pdf.output_file
            result = non_preparer_fields(output_file.path)
            expect(result).to include(
              'form1[0].page3[0].stndardItemizedDeductions[0].form1098[0]' => '',
              'form1[0].page3[0].stndardItemizedDeductions[0].form1098Number[0]' => '',
              'form1[0].page3[0].stndardItemizedDeductions[0].standardDeduction[0]' => '',
              'form1[0].page3[0].stndardItemizedDeductions[0].itemizedDeduction[0]' => '',
              'form1[0].page3[0].stndardItemizedComments[0].stndardItemizedComments[0]' => ''
            )
          end
          it 'works when all choices are all yes and filled in' do
            intake.update(
              cv_1098_cb: 'yes',
              cv_1098_count: 5,
              cv_med_expense_standard_deduction_cb: 'yes',
              cv_med_expense_itemized_deduction_cb: 'yes',
              cv_14c_page_3_notes_part_1: 'section 1 note'
            )

            output_file = intake_pdf.output_file
            result = non_preparer_fields(output_file.path)
            expect(result).to include(
              'form1[0].page3[0].stndardItemizedDeductions[0].form1098[0]' => '1',
              'form1[0].page3[0].stndardItemizedDeductions[0].form1098Number[0]' => '5',
              'form1[0].page3[0].stndardItemizedDeductions[0].standardDeduction[0]' => '1',
              'form1[0].page3[0].stndardItemizedDeductions[0].itemizedDeduction[0]' => '1',
              'form1[0].page3[0].stndardItemizedComments[0].stndardItemizedComments[0]' => 'section 1 note'
            )
          end
        end

        describe 'section 2 on 3' do
          it 'looks good when all choices are no and fields are nil' do
            intake.update(
              cv_1098e_cb: 'no',
              cv_child_dependent_care_credit_cb: 'no',
              contributed_to_ira: 'no',
              cv_edu_expenses_deduction_cb: 'no',
              cv_edu_expenses_deduction_amt: nil,
              cv_paid_alimony_w_spouse_ssn_cb: 'no',
              cv_paid_alimony_w_spouse_ssn_amt: nil,
              cv_alimony_income_adjustment_yn_cb: 'no',
              cv_14c_page_3_notes_part_2: nil,
            )

            output_file = intake_pdf.output_file
            result = non_preparer_fields(output_file.path)
            expect(result).to include(
              'form1[0].page3[0].expensesToReport[0].form1098E[0]' => '',
              'form1[0].page3[0].expensesToReport[0].childDependentCare[0]' => '',
              'form1[0].page3[0].expensesToReport[0].iraBasicRoth[0]' => '',
              'form1[0].page3[0].expensesToReport[0].educatorExpensesDeduction[0]' => '',
              'form1[0].page3[0].expensesToReport[0].educatorExpensesDeductionAmount[0]' => '',
              'form1[0].page3[0].expensesToReport[0].alimonyPayments[0].alimonyPayments[0]' => '',
              'form1[0].page3[0].expensesToReport[0].alimonyPayments[0].alimonyPaymentsAmount[0]' => '',
              'form1[0].page3[0].expensesToReport[0].alimonyPayments[0].adjustementYes[0]' => '',
              'form1[0].page3[0].expensesToReport[0].alimonyPayments[0].adjustementNo[0]' => '1',
              'form1[0].page3[0].expensesReportComments[0].expensesReportComments[0]' => '',
            )
          end

          it 'works when all choices are all yes and filled in' do
            intake.update(
              cv_1098e_cb: 'yes',
              cv_child_dependent_care_credit_cb: 'yes',
              contributed_to_ira: 'yes',
              cv_edu_expenses_deduction_cb: 'yes',
              cv_edu_expenses_deduction_amt: 2814,
              cv_paid_alimony_w_spouse_ssn_cb: 'yes',
              cv_paid_alimony_w_spouse_ssn_amt: 2815,
              cv_alimony_income_adjustment_yn_cb: 'yes',
              cv_14c_page_3_notes_part_2: 'section 2 note!!',
            )

            output_file = intake_pdf.output_file
            result = non_preparer_fields(output_file.path)
            expect(result).to include(
              'form1[0].page3[0].expensesToReport[0].form1098E[0]' => '1',
              'form1[0].page3[0].expensesToReport[0].childDependentCare[0]' => '1',
              'form1[0].page3[0].expensesToReport[0].iraBasicRoth[0]' => '1',
              'form1[0].page3[0].expensesToReport[0].educatorExpensesDeduction[0]' => '1',
              'form1[0].page3[0].expensesToReport[0].educatorExpensesDeductionAmount[0]' => '2814.0',
              'form1[0].page3[0].expensesToReport[0].alimonyPayments[0].alimonyPayments[0]' => '1',
              'form1[0].page3[0].expensesToReport[0].alimonyPayments[0].alimonyPaymentsAmount[0]' => '2815.0',
              'form1[0].page3[0].expensesToReport[0].alimonyPayments[0].adjustementYes[0]' => '1',
              'form1[0].page3[0].expensesToReport[0].alimonyPayments[0].adjustementNo[0]' => '',
              'form1[0].page3[0].expensesReportComments[0].expensesReportComments[0]' => 'section 2 note!!',
            )
          end
        end

        describe 'section 3 on 3 ' do
          it 'looks good when all choices are no and fields are nil' do
            intake.update(
              cv_taxable_scholarship_income_cb: 'no',
              cv_1098t_cb: 'no',
              cv_edu_credit_or_tuition_deduction_cb: 'no',
              cv_1099s_cb: 'no',
              cv_hsa_contrib_cb: 'no',
              cv_hsa_distrib_cb: 'no',
              cv_1095a_cb: 'no',
              cv_energy_efficient_home_improv_credit_cb: 'no',
              cv_1099c_cb: 'no',
              cv_1099a_cb: 'no',
              cv_disaster_relief_impacts_return_cb: 'no',
              cv_eitc_ctc_aotc_hoh_disallowed_in_a_prev_yr_cb: 'no',
              tax_credit_disallowed_year: nil,
              cv_tax_credit_disallowed_reason: nil,
              cv_eligible_for_litc_referral_cb: 'no',
              cv_estimated_tax_payments_cb: 'no',
              cv_estimated_tax_payments_amt: nil,
              cv_last_years_refund_applied_to_this_yr_cb: 'no',
              cv_last_years_refund_applied_to_this_yr_amt: nil,
              cv_last_years_return_available_cb: 'no',
              cv_14c_page_3_notes_part_3: nil,
            )

            output_file = intake_pdf.output_file
            result = non_preparer_fields(output_file.path)
            expect(result).to include(
              'form1[0].page3[0].informationToReport[0].taxableScholarshipIncome[0]' => '',
              'form1[0].page3[0].informationToReport[0].form1098T[0]' => '',
              'form1[0].page3[0].informationToReport[0].educationCreditTuition[0]' => '',
              'form1[0].page3[0].informationToReport[0].saleOfHome[0]' => '',
              'form1[0].page3[0].informationToReport[0].hsaContributions[0]' => '',
              'form1[0].page3[0].informationToReport[0].hsaDistributions[0]' => '',
              'form1[0].page3[0].informationToReport[0].form1095A[0]' => '',
              'form1[0].page3[0].informationToReport[0].efficientHomeImprovement[0]' => '',
              'form1[0].page3[0].informationToReport[0].form1099C[0]' => '',
              'form1[0].page3[0].informationToReport[0].form1099A[0]' => '',
              'form1[0].page3[0].informationToReport[0].disasterReliefImpacts[0]' => '',
              'form1[0].page3[0].informationToReport[0].disallowedPreviousYear[0]' => '',
              'form1[0].page3[0].informationToReport[0].YearDisallowedReason[0].yearDisallowed[0]' => '',
              'form1[0].page3[0].informationToReport[0].YearDisallowedReason[0].reasonDisallowed[0]' => '',
              'form1[0].page3[0].informationToReport[0].eligibleLITCReferral[0]' => '',
              'form1[0].page3[0].informationToReport[0].estimatedTaxPayments[0].estimatedTaxPayments[0]' => '',
              'form1[0].page3[0].informationToReport[0].estimatedTaxPayments[0].taxPaymentsAmount[0]' => '',
              'form1[0].page3[0].informationToReport[0].lastYearsRefund[0].lastYearsRefund[0]' => '',
              'form1[0].page3[0].informationToReport[0].lastYearsRefund[0].refundAmount[0]' => '',
              'form1[0].page3[0].informationToReport[0].lastReturnAvailable[0]' => '',
              'form1[0].page3[0].informationReportComment[0].informationReportComment[0]' => '',
            )
          end

          it 'works when all choices are all yes and filled in' do
            intake.update(
              cv_taxable_scholarship_income_cb: 'yes',
              cv_1098t_cb: 'yes',
              cv_edu_credit_or_tuition_deduction_cb: 'yes',
              cv_1099s_cb: 'yes',
              cv_hsa_contrib_cb: 'yes',
              cv_hsa_distrib_cb: 'yes',
              cv_1095a_cb: 'yes',
              cv_energy_efficient_home_improv_credit_cb: 'yes',
              cv_1099c_cb: 'yes',
              cv_1099a_cb: 'yes',
              cv_disaster_relief_impacts_return_cb: 'yes',
              cv_eitc_ctc_aotc_hoh_disallowed_in_a_prev_yr_cb: 'yes',
              tax_credit_disallowed_year: '2001',
              cv_tax_credit_disallowed_reason: 'an explanation',
              cv_eligible_for_litc_referral_cb: 'yes',
              cv_estimated_tax_payments_cb: 'yes',
              cv_estimated_tax_payments_amt: 2816,
              cv_last_years_refund_applied_to_this_yr_cb: 'yes',
              cv_last_years_refund_applied_to_this_yr_amt: 2817,
              cv_last_years_return_available_cb: 'yes',
              cv_14c_page_3_notes_part_3: 'section 3 note!!!',
            )

            output_file = intake_pdf.output_file
            result = non_preparer_fields(output_file.path)
            expect(result).to include(
              'form1[0].page3[0].informationToReport[0].taxableScholarshipIncome[0]' => '1',
              'form1[0].page3[0].informationToReport[0].form1098T[0]' => '1',
              'form1[0].page3[0].informationToReport[0].educationCreditTuition[0]' => '1',
              'form1[0].page3[0].informationToReport[0].saleOfHome[0]' => '1',
              'form1[0].page3[0].informationToReport[0].hsaContributions[0]' => '1',
              'form1[0].page3[0].informationToReport[0].hsaDistributions[0]' => '1',
              'form1[0].page3[0].informationToReport[0].form1095A[0]' => '1',
              'form1[0].page3[0].informationToReport[0].efficientHomeImprovement[0]' => '1',
              'form1[0].page3[0].informationToReport[0].form1099C[0]' => '1',
              'form1[0].page3[0].informationToReport[0].form1099A[0]' => '1',
              'form1[0].page3[0].informationToReport[0].disasterReliefImpacts[0]' => '1',
              'form1[0].page3[0].informationToReport[0].disallowedPreviousYear[0]' => '1',
              'form1[0].page3[0].informationToReport[0].YearDisallowedReason[0].yearDisallowed[0]' => '2001',
              'form1[0].page3[0].informationToReport[0].YearDisallowedReason[0].reasonDisallowed[0]' => 'an explanation',
              'form1[0].page3[0].informationToReport[0].eligibleLITCReferral[0]' => '1',
              'form1[0].page3[0].informationToReport[0].estimatedTaxPayments[0].estimatedTaxPayments[0]' => '1',
              'form1[0].page3[0].informationToReport[0].estimatedTaxPayments[0].taxPaymentsAmount[0]' => '2816.0',
              'form1[0].page3[0].informationToReport[0].lastYearsRefund[0].lastYearsRefund[0]' => '1',
              'form1[0].page3[0].informationToReport[0].lastYearsRefund[0].refundAmount[0]' => '2817.0',
              'form1[0].page3[0].informationToReport[0].lastReturnAvailable[0]' => '1',
              'form1[0].page3[0].informationReportComment[0].informationReportComment[0]' => 'section 3 note!!!',
            )
          end
        end
      end

      describe "#hash_for_pdf" do
        describe 'additional comments field' do
          let(:additional_comments_key) { "form1[0].page5[0].AdditionalComments[0].AdditionalNotesComments[0]" }

          context "when there are only 3 or less dependents" do
            it "does not reference additional dependents" do
              expect(intake_pdf.hash_for_pdf[additional_comments_key]).to eq("if there is another gnome living in my garden but only i have an income, does that make me head of household?\n\n")
            end
          end

          context "when there are 4 or more dependents" do
            let!(:polly) do
              create(
                :dependent,
                intake: intake,
                first_name: "Polly",
                last_name: "Pony",
                birth_date: Date.new(2018, 8, 27),
                relationship: "Baby",
                months_in_home: 5,
                was_married: "no",
                us_citizen: "no",
                north_american_resident: "yes",
                was_student: "no",
                disabled: "yes",
                has_ip_pin: 'yes',
                can_be_claimed_by_other: 'na',
                provided_over_half_own_support: 'yes',
                below_qualifying_relative_income_requirement: 'no',
                filer_provided_over_half_support: 'na',
                filer_provided_over_half_housing_support: 'yes',
              )
            end
            let!(:patrick) do
              create(
                :dependent,
                intake: intake,
                first_name: "Patrick",
                last_name: "Pony",
                birth_date: Date.new(2019, 3, 11),
                relationship: "Son",
                months_in_home: 8,
                was_married: "no",
                us_citizen: "no",
                north_american_resident: "yes",
                was_student: "no",
                disabled: "no",
                has_ip_pin: 'no',
                can_be_claimed_by_other: 'yes',
                provided_over_half_own_support: 'no',
                below_qualifying_relative_income_requirement: 'na',
                filer_provided_over_half_support: 'yes',
                filer_provided_over_half_housing_support: 'no',
              )
            end

            it "includes extra dependent information in the additional comments field" do
              expect(intake_pdf.hash_for_pdf[additional_comments_key]).to eq(<<~COMMENT)
                if there is another gnome living in my garden but only i have an income, does that make me head of household?

                Additional Dependents:
                Polly Pony // 8/27/2018 // Baby // Months lived in home in 2024: 5 // Single or married in 2024: S // US citizen: N // Resident of US/Canada/Mexico: Y // FT student: N // Disabled: Y // Issued IPPIN: Y // Qualifying child or relative of any other person: N/A // Provided more than 50% of their own support: Y // Had less than $5,050 income: N // Taxpayer(s) provided more than 50% of support: N/A // Taxpayer(s) paid more than half the cost of maintaining home for this person: Y

                Patrick Pony // 3/11/2019 // Son // Months lived in home in 2024: 8 // Single or married in 2024: S // US citizen: N // Resident of US/Canada/Mexico: Y // FT student: N // Disabled: N // Issued IPPIN: N // Qualifying child or relative of any other person: Y // Provided more than 50% of their own support: N // Had less than $5,050 income: N/A // Taxpayer(s) provided more than 50% of support: Y // Taxpayer(s) paid more than half the cost of maintaining home for this person: N\n
              COMMENT
            end
          end

          context "when there is nothing to put in the notes field" do
              before do
                intake.update(additional_notes_comments: nil)
              end

              it "everything still works ok" do
                expect(intake_pdf.hash_for_pdf[additional_comments_key]).to eq("\n\n")
              end
            end
        end
      end

      context "when disclose not consented" do
        let(:intake) do
          create(
            :intake,
            client: build(:client, consented_to_service_at: Date.new(2024, 1, 1)),
            primary_first_name: "Hoofie",
            primary_last_name: "Heifer",
            spouse_first_name: "Hattie",
            spouse_last_name: "Heifer",
          )
        end

        # TODO reenable for TY2024
        xit "15080 fields are nil" do
          output_file = intake_pdf.output_file
          result = non_preparer_fields(output_file.path)
          expect(result).to include(
                              "form1[0].page4[0].primaryTaxpayer[0]" => nil,
                              "form1[0].page4[0].primarydateSigned[0]" => nil,
                              "form1[0].page4[0].secondaryTaxpayer[0]" => nil,
                              "form1[0].page4[0].secondaryDateSigned[0]" => nil
                            )
        end
      end
    end
  end
end
