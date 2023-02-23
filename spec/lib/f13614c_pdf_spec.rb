require "rails_helper"

RSpec.describe F13614cPdf do
  include PdfSpecHelper

  let(:intake_pdf) { described_class.new(intake) }

  describe "#output_file" do
    context "with a complete intake record" do
      let(:intake) do
        create(
          :intake,
          additional_info: "if there is another gnome living in my garden but only i have an income, does that make me head of household?",
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
          final_info: "Also here are some additional notes.",
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
          preferred_written_language: "Greek",
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
          was_student: "no"
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
          was_student: "yes"
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
          was_student: "no"
        )
      end

      it "can successfully write everything that comes out of #hash_for_pdf to the PDF" do
        expect(intake_pdf.hash_for_pdf.length).to be > 100 # sanity check
        form_fields = PdfForms.new.get_fields(intake_pdf.output_file)

        page4_fields = [
          "form1[0].page4[0].Date1[0]",
          "form1[0].page4[0].Date[0]",
          "form1[0].page4[0].primary_taxpayer[0]",
          "form1[0].page4[0].seconde_taxpayer[0]",
        ]
        all_fields_in_pdf = form_fields.map(&:name)
        expect(all_fields_in_pdf - page4_fields).to match_array(intake_pdf.hash_for_pdf.keys)
      end

      it "fills out answers from the DB into the pdf" do
        output_file = intake_pdf.output_file
        result = non_preparer_fields(output_file.path)
        expect(result).to include(
          "form1[0].page1[0].q1_Your_First_Name[0]" => "Hoofie",
          "form1[0].page1[0].q1_Your_Middle_Initial[0]" => "",
          "form1[0].page1[0].q1_Your_Last_Name[0]" => "Heifer",
          "form1[0].page1[0].q1_Telephone_Number[0]" => "(415) 816-1286",
          "form1[0].page1[0].q1_Are_You_A[0].yes[0]" => "Off",
          "form1[0].page1[0].q1_Are_You_A[0].no[0]" => "1",
          "form1[0].page1[0].q2_Spouse_First_Name[0]" => "Hattie",
          "form1[0].page1[0].q2_Spouse_Middle_Initial[0]" => "",
          "form1[0].page1[0].q2_Spouse_Last_Name[0]" => "Heifer",
          "form1[0].page1[0].q2_Telephone_Number[0]" => "",
          "form1[0].page1[0].q2_Is_Your_Spouse[0].yes[0]" => "1",
          "form1[0].page1[0].q2_Is_Your_Spouse[0].no[0]" => "Off",
          "form1[0].page1[0].q3_Mailing_Address[0]" => "789 Garden Green Ln",
          "form1[0].page1[0].p3_Apartment_Number[0]" => "",
          "form1[0].page1[0].q3_City[0]" => "Gardenia",
          "form1[0].page1[0].q3_State[0]" => "NJ",
          "form1[0].page1[0].q3_ZIP_Code[0]" => "08052",
          "form1[0].page1[0].q4_Your_Date_Birth[0]" => "4/19/1961",
          "form1[0].page1[0].q5_Your_Job_Title[0]" => "",
          "form1[0].page1[0].q6_Are_You[0].q6a_Full_Time_Student[0].yes[0]" => "Off",
          "form1[0].page1[0].q6_Are_You[0].q6a_Full_Time_Student[0].no[0]" => "1",
          "form1[0].page1[0].q6_Are_You[0].q6b_Totally_Permanently_Disabled[0].yes[0]" =>
            "1",
          "form1[0].page1[0].q6_Are_You[0].q6b_Totally_Permanently_Disabled[0].no[0]" =>
            "Off",
          "form1[0].page1[0].q6_Are_You[0].q6c_Legally_Blind[0].yes[0]" => "Off",
          "form1[0].page1[0].q6_Are_You[0].q6c_Legally_Blind[0].no[0]" => "1",
          "form1[0].page1[0].q7_Spouse_Date_Birth[0]" => "11/1/1959",
          "form1[0].page1[0].q8_Spouse_Job_Title[0]" => "",
          "form1[0].page1[0].q9_Is_Your_Spouse[0].q9a_Full_Time_Student[0].yes[0]" => "1",
          "form1[0].page1[0].q9_Is_Your_Spouse[0].q9a_Full_Time_Student[0].no[0]" =>
            "Off",
          "form1[0].page1[0].q9_Is_Your_Spouse[0].q9b_Totally_Permanently_Disabled[0].yes[0]" =>
            "Off",
          "form1[0].page1[0].q9_Is_Your_Spouse[0].q9b_Totally_Permanently_Disabled[0].no[0]" =>
            "1",
          "form1[0].page1[0].q9_Is_Your_Spouse[0].q9c_Legally_Blind[0].yes[0]" => "Off",
          "form1[0].page1[0].q9_Is_Your_Spouse[0].q9c_Legally_Blind[0].no[0]" => "1",
          "form1[0].page1[0].q10_Can_Anyone_Claim[0].yes[0]" => "Off",
          "form1[0].page1[0].q10_Can_Anyone_Claim[0].no[0]" => "1",
          "form1[0].page1[0].q10_Can_Anyone_Claim[0].unsure[0]" => "Off",
          "form1[0].page1[0].q11_Have_You_Or[0].yes[0]" => "Off",
          "form1[0].page1[0].q11_Have_You_Or[0].no[0]" => "1",
          "form1[0].page1[0].q12_Email_Address[0]" => "hoofie@heifer.horse",
          "form1[0].page1[0].q1_As_of_December[0].never_married[0]" => "",
          "form1[0].page1[0].q1_As_of_December[0].married[0]" => "1",
          "form1[0].page1[0].q1_As_of_December[0].q1a_Get_Married[0].yes[0]" => "Off",
          "form1[0].page1[0].q1_As_of_December[0].q1a_Get_Married[0].no[0]" => "Off",
          "form1[0].page1[0].q1_As_of_December[0].q1b_Live_With[0].yes[0]" => "1",
          "form1[0].page1[0].q1_As_of_December[0].q1b_Live_With[0].no[0]" => "Off",
          "form1[0].page1[0].q1_As_of_December[0].divorced[0]" => "",
          "form1[0].page1[0].q1_As_of_December[0].Date_Of_Final[0]" => "2015",
          "form1[0].page1[0].q1_As_of_December[0].legally_separated[0]" => "",
          "form1[0].page1[0].q1_As_of_December[0].Date_Of_Separate[0]" => "2016",
          "form1[0].page1[0].q1_As_of_December[0].widowed[0]" => "",
          "form1[0].page1[0].q1_As_of_December[0].Year_Of_Death[0]" => "2017",
          "form1[0].page1[0].additionalSpace[0].additional_space[0]" => "",
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
          "form1[0].page2[0].Part_3[0].q1_Wages_Or_Salary[0].yes[0]" => "1",
          "form1[0].page2[0].Part_3[0].q1_Wages_Or_Salary[0].no[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q1_Wages_Or_Salary[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q1_Wages_Or_Salary[0].Number_of_Jobs[0]" => "5",
          "form1[0].page2[0].Part_3[0].q2_Tip_Income[0].yes[0]" => "1",
          "form1[0].page2[0].Part_3[0].q2_Tip_Income[0].no[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q2_Tip_Income[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q3_Scholarships[0].yes[0]" => "1",
          "form1[0].page2[0].Part_3[0].q3_Scholarships[0].no[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q3_Scholarships[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q4_Interest_Dividends_From[0].yes[0]" => "1",
          "form1[0].page2[0].Part_3[0].q4_Interest_Dividends_From[0].no[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q4_Interest_Dividends_From[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q5_Refund_Of_State[0].yes[0]" => "1",
          "form1[0].page2[0].Part_3[0].q5_Refund_Of_State[0].no[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q5_Refund_Of_State[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q6_Alimony_Income[0].yes[0]" => "1",
          "form1[0].page2[0].Part_3[0].q6_Alimony_Income[0].no[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q6_Alimony_Income[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q7_Self-Employment_Income[0].yes[0]" => "1",
          "form1[0].page2[0].Part_3[0].q7_Self-Employment_Income[0].no[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q7_Self-Employment_Income[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q8_Cash_Check_Payments[0].yes[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q8_Cash_Check_Payments[0].no[0]" => "1",
          "form1[0].page2[0].Part_3[0].q8_Cash_Check_Payments[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q9_Income[0].yes[0]" => "1",
          "form1[0].page2[0].Part_3[0].q9_Income[0].no[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q9_Income[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q10_Disability_Income[0].yes[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q10_Disability_Income[0].no[0]" => "1",
          "form1[0].page2[0].Part_3[0].q10_Disability_Income[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q11_Retirement_Income[0].yes[0]" => "1",
          "form1[0].page2[0].Part_3[0].q11_Retirement_Income[0].no[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q11_Retirement_Income[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q12_Unemployment_Compensation[0].yes[0]" => "1",
          "form1[0].page2[0].Part_3[0].q12_Unemployment_Compensation[0].no[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q12_Unemployment_Compensation[0].unsure[0]" =>
            "Off",
          "form1[0].page2[0].Part_3[0].q13_Social_Security_Or[0].yes[0]" => "1",
          "form1[0].page2[0].Part_3[0].q13_Social_Security_Or[0].no[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q13_Social_Security_Or[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q14_Income_or_Loss[0].yes[0]" => "1",
          "form1[0].page2[0].Part_3[0].q14_Income_or_Loss[0].no[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q14_Income_or_Loss[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q15_Other_Income[0].yes[0]" => "1",
          "form1[0].page2[0].Part_3[0].q15_Other_Income[0].no[0]" => "Off",
          "form1[0].page2[0].Part_3[0].q15_Other_Income[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_4[0].q1_Alimony[0].yes[0]" => "1",
          "form1[0].page2[0].Part_4[0].q1_Alimony[0].no[0]" => "Off",
          "form1[0].page2[0].Part_4[0].q1_Alimony[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_4[0].q1_Alimony[0].If_Yes[0].yes[0]" => "1",
          "form1[0].page2[0].Part_4[0].q1_Alimony[0].If_Yes[0].no[0]" => "Off",
          "form1[0].page2[0].Part_4[0].q2_Contributions[0].yes[0]" => "Off",
          "form1[0].page2[0].Part_4[0].q2_Contributions[0].no[0]" => "Off",
          "form1[0].page2[0].Part_4[0].q2_Contributions[0].unsure[0]" => "1",
          "form1[0].page2[0].Part_4[0].q2_Contributions[0].IRA[0]" => "",
          "form1[0].page2[0].Part_4[0].q2_Contributions[0].Roth_IRA[0]" => "1",
          "form1[0].page2[0].Part_4[0].q2_Contributions[0]._401K[0]" => "1",
          "form1[0].page2[0].Part_4[0].q2_Contributions[0].Other[0]" => "",
          "form1[0].page2[0].Part_4[0].q3_Post_Secondary[0].yes[0]" => "1",
          "form1[0].page2[0].Part_4[0].q3_Post_Secondary[0].no[0]" => "Off",
          "form1[0].page2[0].Part_4[0].q3_Post_Secondary[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_4[0].q4_Deductions[0].yes[0]" => "1",
          "form1[0].page2[0].Part_4[0].q4_Deductions[0].no[0]" => "Off",
          "form1[0].page2[0].Part_4[0].q4_Deductions[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_4[0].q4_Deductions[0].medical[0]" => "1",
          "form1[0].page2[0].Part_4[0].q4_Deductions[0].mortgage[0]" => "",
          "form1[0].page2[0].Part_4[0].q4_Deductions[0].taxes[0]" => "1",
          "form1[0].page2[0].Part_4[0].q4_Deductions[0].charitable[0]" => "",
          "form1[0].page2[0].Part_4[0].q5_Child_Or_Dependent[0].yes[0]" => "Off",
          "form1[0].page2[0].Part_4[0].q5_Child_Or_Dependent[0].no[0]" => "Off",
          "form1[0].page2[0].Part_4[0].q5_Child_Or_Dependent[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_4[0].q6_For_Supplies_Used[0].yes[0]" => "1",
          "form1[0].page2[0].Part_4[0].q6_For_Supplies_Used[0].no[0]" => "Off",
          "form1[0].page2[0].Part_4[0].q6_For_Supplies_Used[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_4[0].q7_Expenses_Related_To[0].yes[0]" => "Off",
          "form1[0].page2[0].Part_4[0].q7_Expenses_Related_To[0].no[0]" => "1",
          "form1[0].page2[0].Part_4[0].q7_Expenses_Related_To[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_4[0].q8_Student_Loan_Interest[0].yes[0]" => "1",
          "form1[0].page2[0].Part_4[0].q8_Student_Loan_Interest[0].no[0]" => "Off",
          "form1[0].page2[0].Part_4[0].q8_Student_Loan_Interest[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_5[0].q1_Have_A_Health[0].yes[0]" => "Off",
          "form1[0].page2[0].Part_5[0].q1_Have_A_Health[0].no[0]" => "1",
          "form1[0].page2[0].Part_5[0].q1_Have_A_Health[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_5[0].q2_Have_Debt_From[0].yes[0]" => "1",
          "form1[0].page2[0].Part_5[0].q2_Have_Debt_From[0].no[0]" => "Off",
          "form1[0].page2[0].Part_5[0].q2_Have_Debt_From[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_5[0].q3_Adopt_A_Child[0].yes[0]" => "Off",
          "form1[0].page2[0].Part_5[0].q3_Adopt_A_Child[0].no[0]" => "1",
          "form1[0].page2[0].Part_5[0].q3_Adopt_A_Child[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_5[0].q4_Have_Earned_Income[0].yes[0]" => "1",
          "form1[0].page2[0].Part_5[0].q4_Have_Earned_Income[0].no[0]" => "Off",
          "form1[0].page2[0].Part_5[0].q4_Have_Earned_Income[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_5[0].q4_Have_Earned_Income[0].Which_Tax_Year[0]" => "2018",
          "form1[0].page2[0].Part_5[0].q5_Purchase_And_Install[0].yes[0]" => "Off",
          "form1[0].page2[0].Part_5[0].q5_Purchase_And_Install[0].no[0]" => "Off",
          "form1[0].page2[0].Part_5[0].q5_Purchase_And_Install[0].unsure[0]" => "1",
          "form1[0].page2[0].Part_5[0].q6_Receive_The_First[0].yes[0]" => "Off",
          "form1[0].page2[0].Part_5[0].q6_Receive_The_First[0].no[0]" => "1",
          "form1[0].page2[0].Part_5[0].q6_Receive_The_First[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_5[0].q7_Make_Estimated_Tax[0].yes[0]" => "Off",
          "form1[0].page2[0].Part_5[0].q7_Make_Estimated_Tax[0].no[0]" => "Off",
          "form1[0].page2[0].Part_5[0].q7_Make_Estimated_Tax[0].unsure[0]" => "1",
          "form1[0].page2[0].Part_5[0].q7_Make_Estimated_Tax[0].How_Much[0]" => "0.0",
          "form1[0].page2[0].Part_5[0].q8_File_A_Federal[0].yes[0]" => "Off",
          "form1[0].page2[0].Part_5[0].q8_File_A_Federal[0].no[0]" => "1",
          "form1[0].page2[0].Part_5[0].q8_File_A_Federal[0].unsure[0]" => "Off",
          "form1[0].page2[0].Part_5[0].q9_have_health[0].yes[0]" => "1",
          "form1[0].page2[0].Part_5[0].q9_have_health[0].no[0]" => "Off",
          "form1[0].page2[0].Part_5[0].q9_have_health[0].unsure[0]" => "Off",
          "form1[0].page3[0].q1[0].yes[0]" => "1",
          "form1[0].page3[0].q1[0].no[0]" => "Off",
          "form1[0].page3[0].q1[0].Which_Language[0]" => "Greek",
          "form1[0].page3[0].q2[0].you[0]" => "1",
          "form1[0].page3[0].q2[0].spouse[0]" => "Off",
          "form1[0].page3[0].q3[0].Direct_Deposit[0].yes[0]" => "1",
          "form1[0].page3[0].q3[0].Direct_Deposit[0].no[0]" => "Off",
          "form1[0].page3[0].q3[0].Savings_Bonds[0].yes[0]" => "1",
          "form1[0].page3[0].q3[0].Savings_Bonds[0].no[0]" => "Off",
          "form1[0].page3[0].q3[0].Different_Accounts[0].yes[0]" => "Off",
          "form1[0].page3[0].q3[0].Different_Accounts[0].no[0]" => "1",
          "form1[0].page3[0].q4[0].yes[0]" => "Off",
          "form1[0].page3[0].q4[0].no[0]" => "1",
          "form1[0].page3[0].q5[0].yes[0]" => "1",
          "form1[0].page3[0].q5[0].no[0]" => "Off",
          "form1[0].page3[0].q5[0].If_Yes_Where[0]" => "Athens",
          "form1[0].page3[0].q6[0].yes[0]" => "Off",
          "form1[0].page3[0].q6[0].no[0]" => "1",
          "form1[0].page3[0].q7[0].yes[0]" => "Off",
          "form1[0].page3[0].q7[0].no[0]" => "1",
          "form1[0].page3[0].q8[0].very_well[0]" => "",
          "form1[0].page3[0].q8[0].well[0]" => "1",
          "form1[0].page3[0].q8[0].not_well[0]" => "",
          "form1[0].page3[0].q8[0].not_at_all[0]" => "",
          "form1[0].page3[0].q8[0].not_answer[0]" => "",
          "form1[0].page3[0].q9[0].very_well[0]" => "",
          "form1[0].page3[0].q9[0].well[0]" => "",
          "form1[0].page3[0].q9[0].not_well[0]" => "1",
          "form1[0].page3[0].q9[0].not_at_all[0]" => "",
          "form1[0].page3[0].q9[0].not_answer[0]" => "",
          "form1[0].page3[0].q10[0].yes[0]" => "1",
          "form1[0].page3[0].q10[0].no[0]" => "",
          "form1[0].page3[0].q10[0].not_answer[0]" => "",
          "form1[0].page3[0].q11[0].yes[0]" => "",
          "form1[0].page3[0].q11[0].no[0]" => "1",
          "form1[0].page3[0].q11[0].not_answer[0]" => "",
          "form1[0].page3[0].q12[0].american_indian[0]" => "",
          "form1[0].page3[0].q12[0].asian[0]" => "",
          "form1[0].page3[0].q12[0].black_african[0]" => "",
          "form1[0].page3[0].q12[0].native_hawaiian[0]" => "1",
          "form1[0].page3[0].q12[0].white[0]" => "1",
          "form1[0].page3[0].q12[0].not_answer[0]" => "",
          "form1[0].page3[0].q13[0].american_indian[0]" => "1",
          "form1[0].page3[0].q13[0].asian[0]" => "",
          "form1[0].page3[0].q13[0].black_african[0]" => "",
          "form1[0].page3[0].q13[0].native_hawaiian[0]" => "",
          "form1[0].page3[0].q13[0].white[0]" => "",
          "form1[0].page3[0].q13[0].not_answer[0]" => "",
          "form1[0].page3[0].q13[0].no_spouse[0]" => "",
          "form1[0].page3[0].q14[0].hispanic_latino[0]" => "",
          "form1[0].page3[0].q14[0].not_hispanic_latino[0]" => "1",
          "form1[0].page3[0].q14[0].not_answer[0]" => "",
          "form1[0].page3[0].q15[0].hispanic_latino[0]" => "",
          "form1[0].page3[0].q15[0].not_hispanic_latino[0]" => "1",
          "form1[0].page3[0].q15[0].not_answer[0]" => "",
          "form1[0].page3[0].q15[0].no_spouse[0]" => "",
          "form1[0].page3[0].Additional_Comments[0].Additional_Comments[1]" =>
            "if there is another gnome living in my garden but only i have an income, does that make me head of household? Also here are some additional notes.\rOther income types: garden gnoming",
          "form1[0].page4[0].primary_taxpayer[0]" => nil,
          "form1[0].page4[0].Date[0]" => nil,
          "form1[0].page4[0].seconde_taxpayer[0]" => nil,
          "form1[0].page4[0].Date1[0]" => nil
        )
  end

      describe "gated questions" do
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
            "form1[0].page2[0].Part_5[0].q6_Receive_The_First[0].yes[0]" => "Off",
            "form1[0].page2[0].Part_5[0].q6_Receive_The_First[0].no[0]" => "1",
            "form1[0].page2[0].Part_5[0].q6_Receive_The_First[0].unsure[0]" => "Off",
            "form1[0].page2[0].Part_4[0].q4_Deductions[0].mortgage[0]" => "",
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
            "form1[0].page2[0].Part_5[0].q6_Receive_The_First[0].yes[0]" => "1",
            "form1[0].page2[0].Part_5[0].q6_Receive_The_First[0].no[0]" => "Off",
            "form1[0].page2[0].Part_5[0].q6_Receive_The_First[0].unsure[0]" => "Off",
            "form1[0].page2[0].Part_4[0].q4_Deductions[0].mortgage[0]" => "1",
          )
        end
      end

      describe "#hash_for_pdf" do
        describe 'additional comments field' do
          let(:additional_comments_key) { "form1[0].page3[0].Additional_Comments[0].Additional_Comments[1]" }

          context "when there are only 3 or less dependents" do
            it "does not reference additional dependents" do
              expect(intake_pdf.hash_for_pdf[additional_comments_key]).to eq(<<~COMMENT.strip)
                if there is another gnome living in my garden but only i have an income, does that make me head of household? Also here are some additional notes.
                Other income types: garden gnoming
              COMMENT
            end
          end

          context "when there are 4 or more dependents" do
            let!(:polly) do
              create(
                :dependent,
                intake: intake,
                first_name: "Polly",
                last_name: "Pony",
                relationship: "Baby",
                birth_date: Date.new(2018, 8, 27),
                months_in_home: 5,
                was_married: "no",
                disabled: "yes",
                north_american_resident: "yes",
                us_citizen: "no",
                was_student: "no",
              )
            end
            let!(:patrick) do
              create(
                :dependent,
                intake: intake,
                first_name: "Patrick",
                last_name: "Pony",
                relationship: "Son",
                birth_date: Date.new(2019, 3, 11),
                months_in_home: 8,
                was_married: "no",
                disabled: "no",
                north_american_resident: "yes",
                us_citizen: "no",
                was_student: "no",
              )
            end

            it "includes extra dependent information in the additional comments field" do
              expect(intake_pdf.hash_for_pdf[additional_comments_key]).to eq(<<~COMMENT.strip)
                if there is another gnome living in my garden but only i have an income, does that make me head of household? Also here are some additional notes.
                Other income types: garden gnoming
                Additional Dependents:
                (a) Polly Pony (b) 8/27/2018 (c) Baby (d) 5 (e) N (f) Y (g) S (h) N (i) Y CVP: ////
                (a) Patrick Pony (b) 3/11/2019 (c) Son (d) 8 (e) N (f) Y (g) S (h) N (i) N CVP: ////
              COMMENT
            end

            context "when there is no additional_info or final_info present" do
              before do
                intake.update(additional_info: nil, final_info: nil)
              end

              it "includes extra dependent information with no leading whitespace" do
                expect(intake_pdf.hash_for_pdf[additional_comments_key]).to eq(<<~COMMENT.strip)
                  Other income types: garden gnoming
                  Additional Dependents:
                  (a) Polly Pony (b) 8/27/2018 (c) Baby (d) 5 (e) N (f) Y (g) S (h) N (i) Y CVP: ////
                  (a) Patrick Pony (b) 3/11/2019 (c) Son (d) 8 (e) N (f) Y (g) S (h) N (i) N CVP: ////
                COMMENT
              end
            end

            context "when a hub user has filled out the CVP information" do
              before do
                polly.update(
                  can_be_claimed_by_other: 'yes',
                  provided_over_half_own_support: 'no',
                  below_qualifying_relative_income_requirement: 'yes',
                  filer_provided_over_half_support: 'no',
                  filer_provided_over_half_housing_support: 'yes',
                )
              end

              it "includes the CVP information after all the lettered dependent columns" do
                expect(intake_pdf.hash_for_pdf[additional_comments_key]).to eq(<<~COMMENT.strip)
                  if there is another gnome living in my garden but only i have an income, does that make me head of household? Also here are some additional notes.
                  Other income types: garden gnoming
                  Additional Dependents:
                  (a) Polly Pony (b) 8/27/2018 (c) Baby (d) 5 (e) N (f) Y (g) S (h) N (i) Y CVP: Y/N/Y/N/Y
                  (a) Patrick Pony (b) 3/11/2019 (c) Son (d) 8 (e) N (f) Y (g) S (h) N (i) N CVP: ////
                COMMENT
              end
            end
          end
        end
      end
    end
  end
end
