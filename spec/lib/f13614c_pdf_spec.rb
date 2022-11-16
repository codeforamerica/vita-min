require "rails_helper"

RSpec.describe F13614cPdf do
  include PdfSpecHelper

  let(:intake_pdf) { described_class.new(intake) }

  describe "#output_file" do
    context "with an empty intake record" do
      let(:intake) { create :intake, current_step: nil }

      it "returns a pdf with default fields and values" do
        output_file = intake_pdf.output_file
        result = non_preparer_fields(output_file.path)
        expect(result).to include(
          "street_address" => "",
          "city" => "",
          "state" => "",
          "zip_code" => "",
          "apt" => nil,

          "never_married" => "",
          "married" => "",
          "lived_with_spouse" => "unfilled",
          "divorced" => "",
          "divorced_date" => "",
          "legally_separated" => "",
          "separated_date" => "",
          "widowed" => "",
          "widowed_date" => "",

          "issued_pin" => "unfilled",
          "email_address" => "",

          "first_name" => "",
          "middle_initial" => "",
          "last_name" => "",
          "date_of_birth" => "",
          "phone_number" => "",
          "job_title" => "",
          "is_citizen" => "",
          "is_disabled" => "unfilled",
          "is_student" => "unfilled",
          "is_blind" => "unfilled",
          "is_on_visa" => "",

          "spouse_first_name" => "",
          "spouse_middle_initial" => "",
          "spouse_last_name" => "",
          "spouse_date_of_birth" => "",
          "spouse_job_title" => "",
          "spouse_is_blind" => "unfilled",
          "spouse_is_disabled" => "unfilled",
          "spouse_is_citizen" => "",
          "spouse_is_student" => "unfilled",
          "spouse_is_on_visa" => "",

          "dependent_1_name" => nil,
          "dependent_1_date_of_birth" => nil,
          "dependent_1_relationship" => nil,
          "dependent_1_months_in_home" => nil,
          "dependent_1_marital_status" => nil,
          "dependent_1_citizen" => nil,
          "dependent_1_resident" => nil,
          "dependent_1_student" => nil,
          "dependent_1_disabled" => nil,
          "dependent_2_name" => nil,
          "dependent_2_date_of_birth" => nil,
          "dependent_2_relationship" => nil,
          "dependent_2_months_in_home" => nil,
          "dependent_2_marital_status" => nil,
          "dependent_2_resident" => nil,
          "dependent_2_student" => nil,
          "dependent_2_disabled" => nil,
          "dependent_2_citizen" => nil,
          "dependent_0_name" => nil,
          "dependent_0_date_of_birth" => nil,
          "dependent_0_relationship" => nil,
          "dependent_0_months_in_home" => nil,
          "dependent_0_marital_status" => nil,
          "dependent_0_citizen" => nil,
          "dependent_0_resident" => nil,
          "dependent_0_student" => nil,
          "dependent_0_disabled" => nil,

          "demographic_english_conversation" => nil,
          "demographic_english_reading" => nil,
          "demographic_household_disability" => nil,
          "demographic_household_veteran" => nil,
          "demographic_primary_race_american_indian_alaska_native" => nil,
          "demographic_primary_race_asian" => nil,
          "demographic_primary_race_black_african_american" => nil,
          "demographic_primary_race_native_hawaiian_pacific_islander" => nil,
          "demographic_primary_race_white" => nil,
          "demographic_primary_race_prefer_not_to_answer_race" => nil,
          "demographic_spouse_race_american_indian_alaska_native" => nil,
          "demographic_spouse_race_asian" => nil,
          "demographic_spouse_race_black_african_american" => nil,
          "demographic_spouse_race_native_hawaiian_pacific_islander" => nil,
          "demographic_spouse_race_white" => nil,
          "demographic_spouse_race_prefer_not_to_answer_race" => nil,
          "demographic_primary_ethnicity" => nil,
          "demographic_spouse_ethnicity" => nil,

          "had_wages" => "unfilled",
          "job_count" => "",
          "had_tips" => "unfilled",
          "had_scholarships" => "",
          "had_interest_income" => "unfilled",
          "had_local_tax_income" => "unfilled",
          "received_alimony" => "unfilled",
          "had_self_employment_income" => "unfilled",
          "had_unreported_income" => "",
          "had_asset_sale_income_loss" => "unfilled",
          "had_disability_income" => "unfilled",
          "had_retirement_income" => "unfilled",
          "had_unemployment_income" => "unfilled",
          "had_social_security_income" => "unfilled",
          "had_rental_income" => "unfilled",
          "had_other_income" => "unfilled",

          "paid_alimony" => "unfilled",
          "have_alimony_recipient_ssn" => "",
          "paid_post_secondary_expenses" => "unfilled",
          "paid_retirement_contributions" => "unfilled",
          "paid_into_traditional_ira" => "",
          "paid_into_401k" => "",
          "paid_into_other_retirement_account" => "",
          "paid_into_roth_ira" => "",

          "had_misc_expenses" => "unfilled",
          "paid_local_tax"  => "",
          "paid_mortgage_interest" => "",
          "paid_medical_expenses" => "",
          "paid_charitable_contributions" => "",
          "paid_dependent_care" => "unfilled",
          "paid_school_supplies" => "unfilled",
          "paid_self_employment_expenses" => "",
          "paid_student_loan_interest" => "unfilled",

          "had_hsa" => "unfilled",
          "had_debt_forgiven" => "unfilled",
          "adopted_child" => "unfilled",
          "had_tax_credit_disallowed" => "unfilled",
          "bought_energy_efficient_items" => "unfilled",
          "received_homebuyer_credit" => "unfilled",
          "made_estimated_tax_payments" => "unfilled",
          "filed_capital_loss_carryover" => "",
          "bought_health_insurance" => "unfilled",
          "received_stimulus_payment" => "unfilled",
          "received_advance_ctc_payment" => "",
          "eip1_amount_received" => "",
          "eip2_amount_received" => "",
          "eip3_amount_received" => "",
          "advance_ctc_amount_received" =>  "",
          "other_written_communication_language" => "no",
          "preferred_written_language" => "",
          "direct_deposit" => "unfilled",
          "savings_purchase_bond" => "unfilled",
          "savings_split_refund" => "unfilled",
          "balance_due_transfer" => "unfilled",
          "had_disaster_loss" => "unfilled",
          "received_irs_letter" => "unfilled",
          "additional_comments" => "",
          "claimed_by_another" => "unfilled"
        )
      end
    end

    context "with a complete intake record" do
      let(:intake) do
        create(
          :intake,
          primary_first_name: "Hoofie",
          primary_last_name: "Heifer",
          primary_birth_date: Date.new(1961, 4, 19),
          email_address: "hoofie@heifer.horse",
          phone_number: "+14158161286",
          spouse_first_name: "Hattie",
          spouse_last_name: "Heifer",
          spouse_birth_date: Date.new(1959, 11, 1),
          primary_consented_to_service: "yes",
          spouse_consented_to_service: "yes",
          filing_joint: "yes",
          street_address: "789 Garden Green Ln",
          city: "Gardenia",
          state: "nj",
          zip_code: "08052",
          multiple_states: "yes",
          ever_married: "yes",
          married: "yes",
          lived_with_spouse: "yes",
          divorced: "no",
          divorced_year: "2015",
          separated: "no",
          separated_year: "2016",
          widowed: "no",
          widowed_year: "2017",
          had_wages: "yes",
          had_tips: "yes",
          had_retirement_income: "yes",
          had_social_security_income: "yes",
          had_unemployment_income: "yes",
          had_disability_income: "no",
          had_interest_income: "yes",
          had_asset_sale_income: "yes",
          reported_asset_sale_loss: "yes",
          received_alimony: "yes",
          had_rental_income: "yes",
          had_farm_income: "no",
          had_gambling_income: "yes",
          had_local_tax_refund: "yes",
          had_self_employment_income: "yes",
          reported_self_employment_loss: "yes",
          had_other_income: "yes",
          other_income_types: "garden gnoming",
          paid_mortgage_interest: "no",
          paid_local_tax: "yes",
          paid_medical_expenses: "yes",
          paid_charitable_contributions: "no",
          paid_student_loan_interest: "yes",
          paid_dependent_care: "unfilled",
          paid_retirement_contributions: "unsure",
          paid_school_supplies: "yes",
          paid_alimony: "yes",
          had_student_in_family: "no",
          sold_a_home: "no",
          had_hsa: "no",
          bought_health_insurance: "yes",
          received_homebuyer_credit: "yes",
          had_debt_forgiven: "yes",
          had_disaster_loss: "yes",
          adopted_child: "no",
          had_tax_credit_disallowed: "yes",
          received_irs_letter: "no",
          bought_energy_efficient_items: "unsure",
          made_estimated_tax_payments: "unsure",
          additional_info: "if there is another gnome living in my garden but only i have an income, does that make me head of household?",
          final_info: "Also here are some additional notes.",
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
          was_full_time_student: "no",
          was_on_visa: "yes",
          had_disability: "yes",
          was_blind: "no",
          issued_identity_pin: "no",
          spouse_was_full_time_student: "yes",
          spouse_was_on_visa: "unfilled",
          spouse_had_disability: "no",
          spouse_was_blind: "no",
          spouse_issued_identity_pin: "no",
          refund_payment_method: "direct_deposit",
          savings_purchase_bond: "yes",
          savings_split_refund: "no",
          balance_pay_from_bank: "no",
          claimed_by_another: "no",
          job_count: 5,
          received_stimulus_payment: "yes",
          received_advance_ctc_payment: "yes",
          advance_ctc_amount_received: 500,
          eip1_amount_received: 500,
          eip2_amount_received: 1500,
          eip3_amount_received: 2500,
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
          on_visa: "no",
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
          on_visa: "no",
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
          on_visa: "yes",
          was_student: "no"
        )
      end

      it "returns a filled out pdf" do
        output_file = intake_pdf.output_file
        result = non_preparer_fields(output_file.path)
        expect(result).to include(
           "advance_ctc_amount_received" => "500",
           "first_name" => "Hoofie",
           "middle_initial" => "",
           "last_name" => "Heifer",
           "date_of_birth" => "4/19/1961",
           "spouse_first_name" => "Hattie",
           "spouse_middle_initial" => "",
           "spouse_last_name" => "Heifer",
           "spouse_date_of_birth" => "11/1/1959",
           "claimed_by_another" => "no",
           "spouse_is_on_visa" => "",
           "is_on_visa" => "yes",

           "street_address" => "789 Garden Green Ln",
           "apt" => nil,
           "city" => "Gardenia",
           "state" => "NJ",
           "zip_code" => "08052",
           "phone_number" => "(415) 816-1286",
           "email_address" => "hoofie@heifer.horse",
           "is_student" => "no",
           "spouse_is_student" => "yes",
           "is_blind" => "no",
           "spouse_is_blind" => "no",
           "is_disabled" => "yes",
           "spouse_is_disabled" => "no",
           "is_citizen" => "",
           "spouse_is_citizen" => "",
           "issued_pin" => "no",
           "job_title" => "",


           "direct_deposit" => "yes",
           "savings_split_refund" => "no",
           "savings_purchase_bond" => "yes",
           "balance_due_transfer" => "no",

           "never_married" => "",
           "married" => "yes",
           "lived_with_spouse" => "yes",
           "divorced" => "",
           "divorced_date" => "2015",
           "legally_separated" => "",
           "separated_date" => "2016",
           "widowed" => "",
           "widowed_date" => "2017",
           "married_during_tax_year" => "",
           "other_income_types" => "garden gnoming",
           "other_written_communication_language" => "no",
           "eip1_amount_received" => "500",
           "eip2_amount_received" => "1500",
           "eip3_amount_received" => "2500",
           "had_misc_expenses" => "yes",

           #
           "dependent_0_name" => "Percy Pony",
           "dependent_0_date_of_birth" => "3/2/2005",
           "dependent_0_relationship" => "Child",
           "dependent_0_months_in_home" => "12",
           "dependent_0_marital_status" => "S",
           "dependent_0_citizen" => "",
           "dependent_0_resident" => "Y",
           "dependent_0_student" => "N",
           "dependent_0_disabled" => "N",
           "dependent_1_name" => "Parker Pony",
           "dependent_1_date_of_birth" => "12/10/2001",
           "dependent_1_relationship" => "Some kid at my house",
           "dependent_1_months_in_home" => "4",
           "dependent_1_marital_status" => "M",
           "dependent_1_resident" => "Y",
           "dependent_1_student" => "Y",
           "dependent_1_disabled" => "N",
           "dependent_1_citizen" => "",
           "dependent_2_name" => "Penny Pony",
           "dependent_2_date_of_birth" => "10/15/2010",
           "dependent_2_relationship" => "Progeny",
           "dependent_2_months_in_home" => "12",
           "dependent_2_marital_status" => "S",
           "dependent_2_citizen" => "On Visa",
           "dependent_2_resident" => "Y",
           "dependent_2_student" => "N",
           "dependent_2_disabled" => "Y",
         #
           "demographic_english_conversation" => "well",
           "demographic_english_reading" => "not_well",
           "demographic_household_disability" => "yes",
           "demographic_household_veteran" => "no",
           "demographic_primary_race_american_indian_alaska_native" => "",
           "demographic_primary_race_asian" => "",
           "demographic_primary_race_black_african_american" => "",
           "demographic_primary_race_native_hawaiian_pacific_islander" => "yes",
           "demographic_primary_race_white" => "yes",
           "demographic_primary_race_prefer_not_to_answer_race" => "",
           "demographic_spouse_race_american_indian_alaska_native" => "yes",
           "demographic_spouse_race_asian" => "",
           "demographic_spouse_race_black_african_american" => "",
           "demographic_spouse_race_native_hawaiian_pacific_islander" => "",
           "demographic_spouse_race_white" => "",
           "demographic_spouse_race_prefer_not_to_answer_race" => "",
           "demographic_primary_ethnicity" => "not_hispanic_latino",
           "demographic_spouse_ethnicity" => "not_hispanic_latino",
         #
           "had_wages" => "yes",
           "job_count" => "5",
           "had_tips" => "yes",
           "had_retirement_income" => "yes",
           "had_social_security_income" => "yes",
           "had_unemployment_income" => "yes",
           "had_disability_income" => "no",
           "had_interest_income" => "yes",
           "had_asset_sale_income_loss" => "yes",
           "received_alimony" => "yes",
           "received_advance_ctc_payment" => "yes",
           "had_rental_income" => "yes",
           "had_local_tax_income" => "yes",
           "had_self_employment_income" => "yes",
           "had_other_income" => "yes",
           "paid_mortgage_interest" => "",
           "paid_local_tax"  => "yes",
           "paid_medical_expenses" => "yes",
           "paid_charitable_contributions" => "",
           "paid_student_loan_interest" => "yes",
           "paid_dependent_care" => "unfilled",
           "paid_retirement_contributions" => "unsure",
           "paid_school_supplies" => "yes",
           "paid_alimony" => "yes",
           "paid_post_secondary_expenses" => "no",
           "paid_into_401k" => "",
           "paid_into_other_retirement_account" => "",
           "paid_into_roth_ira" => "",
           "paid_into_traditional_ira" => "",
           "had_hsa" => "no",
           "bought_health_insurance" => "yes",
           "received_homebuyer_credit" => "yes",
           "bought_energy_efficient_items" => "unsure",
           "had_debt_forgiven" => "yes",
           "had_disaster_loss" => "yes",
           "adopted_child" => "no",
           "had_tax_credit_disallowed" => "yes",
           "received_irs_letter" => "no",
           "made_estimated_tax_payments" => "unsure",
           "received_stimulus_payment" => "yes",
           "additional_comments" => "if there is another gnome living in my garden but only i have an income, does that make me head of household? Also here are some additional notes.",
        )
      end

      describe "#hash_for_pdf" do
        describe 'additional comments field' do
          context "when there are only 3 or less dependents" do
            it "does not reference additional dependents" do
              expect(intake_pdf.hash_for_pdf[:additional_comments]).to eq(<<~COMMENT.strip)
                if there is another gnome living in my garden but only i have an income, does that make me head of household? Also here are some additional notes.
              COMMENT
            end
          end

          context "when there are 4 or more dependents" do
            before do
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
                on_visa: "no",
                was_student: "no",
              )
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
                on_visa: "no",
                was_student: "no",
              )
            end

            it "includes extra dependent information in the additional comments field" do
              expect(intake_pdf.hash_for_pdf[:additional_comments]).to eq(<<~COMMENT.strip)
                if there is another gnome living in my garden but only i have an income, does that make me head of household? Also here are some additional notes.
                
                Additional Dependents:
                (a) Polly Pony (b) 8/27/2018 (c) Baby (d) 5 (e) Y (f) Y (g)  (h) N (i) S
                (a) Patrick Pony (b) 3/11/2019 (c) Son (d) 8 (e) N (f) Y (g)  (h) N (i) S
              COMMENT
            end

            context "when there is no additional_info or final_info present" do
              before do
                intake.update(additional_info: nil, final_info: nil)
              end

              it "includes extra dependent information with no leading whitespace" do
                expect(intake_pdf.hash_for_pdf[:additional_comments]).to eq(<<~COMMENT.strip)
                  Additional Dependents:
                  (a) Polly Pony (b) 8/27/2018 (c) Baby (d) 5 (e) Y (f) Y (g)  (h) N (i) S
                  (a) Patrick Pony (b) 3/11/2019 (c) Son (d) 8 (e) N (f) Y (g)  (h) N (i) S
                COMMENT
              end
            end
          end
        end
      end
    end
  end
end
