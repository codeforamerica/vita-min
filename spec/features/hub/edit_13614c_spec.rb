require "rails_helper"

RSpec.describe "a user editing a clients 13614c form" do
  around do |example|
    Timecop.freeze(DateTime.strptime('2021-03-04 5:10 PST', '%F %R %Z')) do
      example.run
    end
  end

  context "as an admin user" do
    let(:organization) { create(:organization, name: "Assigned Org") }
    let!(:new_site) { create(:site, name: "Other Site") }

    let(:user) { create :admin_user }
    let(:assigned_user) { create :user, role: create(:organization_lead_role, organization: organization) }
    let(:tax_return) { build :gyr_tax_return, assigned_user: assigned_user, filing_status: nil }
    let(:client) {
      create :client,
             vita_partner: organization,
             tax_returns: [tax_return],
             intake: build(:intake,
                            primary_ssn: "123456789",
                            spouse_ssn: "111423256",
                            primary_tin_type: "ssn",
                            spouse_tin_type: "ssn",
                            email_address: "colleen@example.com",
                            filing_joint: "yes",
                            primary_first_name: "Colleen",
                            primary_last_name: "Cauliflower",
                            preferred_interview_language: "es",
                            state_of_residence: "CA",
                            preferred_name: "Colleen Cauliflower",
                            email_notification_opt_in: "yes",
                            timezone: "America/Chicago",
                            ever_married: "no",
                            was_blind: "no",
                            was_full_time_student: "unsure",
                            claimed_by_another: "unsure",
                            had_disability: "unsure",
                            spouse_was_blind: "no",
                            spouse_had_disability: "no",
                            spouse_was_full_time_student: "no",
                            issued_identity_pin: "unsure",
                            lived_with_spouse: "unsure",
                            dependents: [
                              create(:dependent, first_name: "Lara", last_name: "Legume", birth_date: "2007-03-06"),
                            ],
                            # page 2
                            job_count: 2,
                            had_tips: "yes",
                            made_estimated_tax_payments: "yes",
                            had_interest_income: "no",
                            had_local_tax_refund: "unsure",
                            paid_alimony: "yes",
                            had_self_employment_income: "no",
             )

    }
    before { login_as user }

    scenario "I can see and update the 13614c page 1 form" do
      visit hub_client_path(id: client.id)
      within ".client-profile" do
        click_on "Edit 13614-C"
      end

      expect(page).to have_text "Part I – Your Personal Information"
      within "#primary-info" do
        fill_in 'First Name', with: 'Emily'
      end

      fill_in 'hub_update13614c_form_page1_primary_birth_date_month', with: '11'
      fill_in 'hub_update13614c_form_page1_primary_birth_date_day', with: '30'
      fill_in 'hub_update13614c_form_page1_primary_birth_date_year', with: '1999'

      fill_in 'hub_update13614c_form_page1_spouse_birth_date_month', with: '10'
      fill_in 'hub_update13614c_form_page1_spouse_birth_date_day', with: '20'
      fill_in 'hub_update13614c_form_page1_spouse_birth_date_year', with: '1998'

      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page1.fields.receive_written_communication")
      fill_in I18n.t("hub.clients.edit_13614c_form_page1.fields.preferred_written_language"), with: "Chinese"
      select "You", from: I18n.t("hub.clients.edit_13614c_form_page1.fields.presidential_campaign_fund")

      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page1.fields.refund_payment_method_direct_deposit")
      select "No", from: I18n.t("hub.clients.edit_13614c_form_page1.fields.refund_check_by_mail")
      fill_in 'hub_update13614c_form_page1_refund_other', with: "Purchase US Savings Bond"
      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page1.fields.refund_payment_method_split")

      select "No", from: I18n.t("hub.clients.edit_13614c_form_page1.fields.pay_due_balance_directly")

      select "No", from: I18n.t("hub.clients.edit_13614c_form_page1.fields.register_to_vote")

      # multiple_states field
      select "No", from: I18n.t("hub.clients.edit_13614c_form_page1.fields.lived_or_worked_in_two_or_more_states")

      within "#dependents-fields" do
        expect(find_field("hub_update13614c_form_page1[dependents_attributes][0][first_name]").value).to eq "Lara"

        fill_in "hub_update13614c_form_page1_dependents_attributes_0_first_name", with: "Laura"
        fill_in "hub_update13614c_form_page1_dependents_attributes_0_last_name", with: "Peaches"
        fill_in "hub_update13614c_form_page1_dependents_attributes_0_birth_date_month", with: "12"
        fill_in "hub_update13614c_form_page1_dependents_attributes_0_birth_date_day", with: "1"
        fill_in "hub_update13614c_form_page1_dependents_attributes_0_birth_date_year", with: "2008"
        select "9", from: "hub_update13614c_form_page1_dependents_attributes_0_months_in_home"
        select "Y", from: "hub_update13614c_form_page1_dependents_attributes_0_north_american_resident"
        select "Y", from: "hub_update13614c_form_page1_dependents_attributes_0_us_citizen"
      end
      click_on 'Save'

      # Stay on current page upon save
      within(".flash--notice") do
        expect(page).to have_text "Changes saved"
      end

      expect(page).to have_text "Part I – Your Personal Information"
      expect(page).to have_field('First Name', with: 'Emily')
      expect(find_field("hub_update13614c_form_page1[primary_birth_date_year]").value).to eq "1999"
      expect(find_field("hub_update13614c_form_page1[primary_birth_date_day]").value).to eq "30"
      expect(find_field("hub_update13614c_form_page1[primary_birth_date_month]").value).to eq "11"

      expect(find_field("hub_update13614c_form_page1[spouse_birth_date_year]").value).to eq "1998"
      expect(find_field("hub_update13614c_form_page1[spouse_birth_date_day]").value).to eq "20"
      expect(find_field("hub_update13614c_form_page1[spouse_birth_date_month]").value).to eq "10"

      expect(find_field("hub_update13614c_form_page1[receive_written_communication]").value).to eq "yes"
      expect(find_field("hub_update13614c_form_page1[preferred_written_language]").value).to eq "Chinese"
      expect(find_field("hub_update13614c_form_page1[presidential_campaign_fund_donation]").value).to eq "primary"
      expect(find_field("hub_update13614c_form_page1[refund_direct_deposit]").value).to eq "yes"
      expect(find_field("hub_update13614c_form_page1[refund_check_by_mail]").value).to eq "no"
      expect(find_field("hub_update13614c_form_page1[savings_split_refund]").value).to eq "yes"
      expect(find_field("hub_update13614c_form_page1[refund_other]").value).to eq "Purchase US Savings Bond"
      expect(find_field("hub_update13614c_form_page1[balance_pay_from_bank]").value).to eq "no"
      expect(find_field("hub_update13614c_form_page1[register_to_vote]").value).to eq "no"
      expect(find_field("hub_update13614c_form_page1[multiple_states]").value).to eq "no"

      expect(page).to have_text('Last client 13614-C update: Mar 4 5:10 AM')
      within "#dependents-fields" do
        expect(find_field("hub_update13614c_form_page1[dependents_attributes][0][first_name]").value).to eq "Laura"
        expect(find_field("hub_update13614c_form_page1[dependents_attributes][0][birth_date_month]").value).to eq "12"
        expect(find_field("hub_update13614c_form_page1[dependents_attributes][0][birth_date_day]").value).to eq "1"
        expect(find_field("hub_update13614c_form_page1[dependents_attributes][0][birth_date_year]").value).to eq "2008"
      end
    end

    scenario "When I click to another page without saving, my progress is not saved and I get a confirmation dialogue before proceeding", js: true do
      visit hub_client_path(id: client.id)
      within ".client-profile" do
        click_on "Edit 13614-C"
      end

      within "#primary-info" do
        fill_in 'First Name', with: 'Bloop'
      end

      within '.form_13614c-page-links', match: :first do
        click_on "2"
      end

      expect(page).to have_text I18n.t("hub.clients.edit_13614c_form_page2.part_3_title")
      expect(client.intake.reload.primary_first_name).to eq "Colleen"
    end

    scenario "When I cancel from 13614c page 2, my progress is not saved and I get routed back to the client hub", js: true do
      visit hub_client_path(id: client.id)
      within ".client-profile" do
        click_on "Edit 13614-C"
      end

      within '.form_13614c-page-links', match: :first do
        click_on "2"
      end

      within "#income-fields" do
        select "Yes", from: "hub_update13614c_form_page2_had_wages"
      end

      page.dismiss_prompt I18n.t('general.confirm_exit_without_saving') do
        click_on I18n.t("general.cancel")
      end

      expect(page).to have_text I18n.t("hub.clients.edit_13614c_form_page2.part_3_title")

      page.accept_alert I18n.t('general.confirm_exit_without_saving') do
        click_on I18n.t("general.cancel")
      end
      expect(page).to have_text("Edit 13614-C") # navigated back to client profile

      intake = client.intake.reload
      expect(intake.had_wages_yes?).to eq false # check that we did not persist information
    end

    scenario "I can see and update the 13614c page 2 form", js: true do
      visit hub_client_path(id: client.id)
      within ".client-profile" do
        click_on "Edit 13614-C"
      end

      within '.form_13614c-page-links', match: :first do
        click_on "2"
      end
      expect(page).to have_text I18n.t("hub.clients.edit_13614c_form_page2.title")

      expect(page).to have_text "Income – Last Year, Did You (or Your Spouse) Receive"

      expect(find_field("hub_update13614c_form_page2[job_count]").value).to eq "2"

      # left column #

      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page2.fields.had_wages")
      select "3", from: I18n.t("hub.clients.edit_13614c_form_page2.fields.job_count")
      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page2.fields.had_tips")
      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page2.fields.had_retirement_income")
      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page2.fields.had_disability_income")
      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page2.fields.had_social_security_income")
      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page2.fields.had_unemployment_income")
      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page2.fields.had_local_tax_refund")
      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page2.fields.had_interest_income")
      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page2.fields.had_asset_sale_income")
      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page2.fields.reported_asset_sale_loss")
      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page2.fields.received_alimony")
      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page2.fields.had_rental_income")
      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page2.fields.had_rental_income_and_used_dwelling_as_residence")
      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page2.fields.had_rental_income_from_personal_property")
      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page2.fields.had_gambling_income")
      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page2.fields.had_self_employment_income")
      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page2.fields.reported_self_employment_loss")
      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page2.fields.had_other_income")

      # right column #

      select "Yes", from: "hub_update13614c_form_page2_cv_w2s_cb"
      select "5", from: "hub_update13614c_form_page2_cv_w2s_count"

      select "Yes", from: "hub_update13614c_form_page2_cv_had_tips_cb"

      select "Yes", from: "hub_update13614c_form_page2_cv_1099r_cb"
      select "5", from: "hub_update13614c_form_page2_cv_1099r_count"
      select "Yes", from: "hub_update13614c_form_page2_cv_1099r_charitable_dist_cb"
      fill_in "hub_update13614c_form_page2_cv_1099r_charitable_dist_amt", with: 2814

      select "Yes", from: "hub_update13614c_form_page2_cv_disability_benefits_1099r_or_w2_cb"
      select "5", from: "hub_update13614c_form_page2_cv_disability_benefits_1099r_or_w2_count"

      select "Yes", from: "hub_update13614c_form_page2_cv_ssa1099_rrb1099_cb"
      select "5", from: "hub_update13614c_form_page2_cv_ssa1099_rrb1099_count"

      select "Yes", from: "hub_update13614c_form_page2_cv_1099g_cb"
      select "5", from: "hub_update13614c_form_page2_cv_1099g_count"

      select "Yes", from: "hub_update13614c_form_page2_cv_local_tax_refund_cb"
      fill_in "hub_update13614c_form_page2_cv_local_tax_refund_amt", with: 2815
      select "Yes", from: "hub_update13614c_form_page2_cv_itemized_last_year_cb"

      select "Yes", from: "hub_update13614c_form_page2_cv_1099int_cb"
      select "5", from: "hub_update13614c_form_page2_cv_1099int_count"
      select "Yes", from: "hub_update13614c_form_page2_cv_1099div_cb"
      select "5", from: "hub_update13614c_form_page2_cv_1099div_count"

      select "Yes", from: "hub_update13614c_form_page2_cv_1099b_cb"
      select "5", from: "hub_update13614c_form_page2_cv_1099b_count"
      select "Yes", from: "hub_update13614c_form_page2_cv_capital_loss_carryover_cb"

      select "Yes", from: "hub_update13614c_form_page2_cv_alimony_income_cb"
      fill_in "hub_update13614c_form_page2_cv_alimony_income_amt", with: 2816
      select "Yes", from: "hub_update13614c_form_page2_cv_alimony_excluded_from_income_cb"

      select "Yes", from: "hub_update13614c_form_page2_cv_rental_income_cb"
      select "Yes", from: "hub_update13614c_form_page2_cv_rental_expense_cb"
      fill_in "hub_update13614c_form_page2_cv_rental_expense_amt", with: 2817

      select "Yes", from: "hub_update13614c_form_page2_cv_w2g_or_other_gambling_winnings_cb"
      select "5", from: "hub_update13614c_form_page2_cv_w2g_or_other_gambling_winnings_count"

      select "Yes", from: "hub_update13614c_form_page2_cv_schedule_c_cb"
      select "Yes", from: "hub_update13614c_form_page2_cv_1099misc_cb"
      select "5", from: "hub_update13614c_form_page2_cv_1099misc_count"
      select "Yes", from: "hub_update13614c_form_page2_cv_1099nec_cb"
      select "5", from: "hub_update13614c_form_page2_cv_1099nec_count"
      select "Yes", from: "hub_update13614c_form_page2_cv_1099k_cb"
      select "5", from: "hub_update13614c_form_page2_cv_1099k_count"
      select "Yes", from: "hub_update13614c_form_page2_cv_other_income_reported_elsewhere_cb"
      select "Yes", from: "hub_update13614c_form_page2_cv_schedule_c_expenses_cb"
      fill_in "hub_update13614c_form_page2_cv_schedule_c_expenses_amt", with: 2818

      select "Yes", from: "hub_update13614c_form_page2_cv_other_income_cb"

      fill_in "hub_update13614c_form_page2_cv_p2_notes_comments", with: "Hello"

      click_on I18n.t("general.save")

      expect(page).to have_text I18n.t("hub.clients.edit_13614c_form_page2.title")
      expect(page).to have_text I18n.t("general.changes_saved")

      # left column #

      intake = client.intake.reload
      expect(intake.had_wages_yes?).to eq true
      expect(intake.had_wages).to eq 'yes'
      expect(intake.job_count).to eq 3
      expect(intake.had_tips_yes?).to eq true
      expect(intake.had_retirement_income_yes?).to eq true
      expect(intake.had_disability_income_yes?).to eq true
      expect(intake.had_social_security_income_yes?).to eq true
      expect(intake.had_unemployment_income_yes?).to eq true
      expect(intake.had_local_tax_refund_yes?).to eq true
      expect(intake.had_interest_income_yes?).to eq true
      expect(intake.had_asset_sale_income_yes?).to eq true
      expect(intake.reported_asset_sale_loss_yes?).to eq true
      expect(intake.received_alimony?).to eq true
      expect(intake.had_rental_income_yes?).to eq true
      expect(intake.had_rental_income_and_used_dwelling_as_residence_yes?).to eq true
      expect(intake.had_rental_income_from_personal_property_yes?).to eq true
      expect(intake.had_gambling_income_yes?).to eq true
      expect(intake.had_self_employment_income_yes?).to eq true
      expect(intake.reported_self_employment_loss_yes?).to eq true
      expect(intake.had_other_income_yes?).to eq true

      # right column #

      expect(intake.cv_w2s_cb_yes?).to eq true
      expect(intake.cv_w2s_count).to eq 5

      expect(intake.cv_had_tips_cb_yes?).to eq true

      expect(intake.cv_1099r_cb_yes?).to eq true
      expect(intake.cv_1099r_count).to eq 5
      expect(intake.cv_1099r_charitable_dist_cb_yes?).to eq true
      expect(intake.cv_1099r_charitable_dist_amt).to eq 2814

      expect(intake.cv_disability_benefits_1099r_or_w2_cb_yes?).to eq true
      expect(intake.cv_disability_benefits_1099r_or_w2_count).to eq 5

      expect(intake.cv_ssa1099_rrb1099_cb_yes?).to eq true
      expect(intake.cv_ssa1099_rrb1099_count).to eq 5

      expect(intake.cv_1099g_cb_yes?).to eq true
      expect(intake.cv_1099g_count).to eq 5

      expect(intake.cv_local_tax_refund_cb_yes?).to eq true
      expect(intake.cv_local_tax_refund_amt).to eq 2815
      expect(intake.cv_itemized_last_year_cb_yes?).to eq true

      expect(intake.cv_1099int_cb_yes?).to eq true
      expect(intake.cv_1099int_count).to eq 5
      expect(intake.cv_1099div_cb_yes?).to eq true
      expect(intake.cv_1099div_count).to eq 5

      expect(intake.cv_1099b_cb_yes?).to eq true
      expect(intake.cv_1099b_count).to eq 5
      expect(intake.cv_capital_loss_carryover_cb_yes?).to eq true

      expect(intake.cv_alimony_income_cb_yes?).to eq true
      expect(intake.cv_alimony_income_amt).to eq 2816
      expect(intake.cv_alimony_excluded_from_income_cb_yes?).to eq true

      expect(intake.cv_rental_income_cb_yes?).to eq true
      expect(intake.cv_rental_expense_cb_yes?).to eq true
      expect(intake.cv_rental_expense_amt).to eq 2817

      expect(intake.cv_w2g_or_other_gambling_winnings_cb_yes?).to eq true
      expect(intake.cv_w2g_or_other_gambling_winnings_count).to eq 5

      expect(intake.cv_schedule_c_cb_yes?).to eq true
      expect(intake.cv_1099misc_cb_yes?).to eq true
      expect(intake.cv_1099misc_count).to eq 5
      expect(intake.cv_1099nec_cb_yes?).to eq true
      expect(intake.cv_1099nec_count).to eq 5
      expect(intake.cv_1099k_cb_yes?).to eq true
      expect(intake.cv_1099k_count).to eq 5
      expect(intake.cv_other_income_reported_elsewhere_cb_yes?).to eq true
      expect(intake.cv_schedule_c_expenses_cb_yes?).to eq true
      expect(intake.cv_schedule_c_expenses_amt).to eq 2818

      expect(intake.cv_other_income_cb_yes?).to eq true

      expect(intake.cv_p2_notes_comments).to eq "Hello"
    end

    scenario "I can see and update the 13614c page 3 form", js: true do
      visit hub_client_path(id: client.id)
      within ".client-profile" do
        click_on "Edit 13614-C"
      end

      within '.form_13614c-page-links', match: :first do
        click_on "3"
      end
      expect(page).to have_text I18n.t("hub.clients.edit_13614c_form_page3.title")

      expect(page).to have_text "Expenses and Tax Related Events"

      select "Yes", from: "hub_update13614c_form_page3_paid_mortgage_interest"
      select "Yes", from: "hub_update13614c_form_page3_cv_1098_cb"
      select "5", from: "hub_update13614c_form_page3_cv_1098_count"

      select "Yes", from: "hub_update13614c_form_page3_paid_local_tax"

      select "Yes", from: "hub_update13614c_form_page3_paid_medical_expenses"
      select "Yes", from: "hub_update13614c_form_page3_cv_med_expense_standard_deduction_cb"
      select "Yes", from: "hub_update13614c_form_page3_cv_med_expense_itemized_deduction_cb"

      select "Yes", from: "hub_update13614c_form_page3_paid_charitable_contributions"

      fill_in "hub_update13614c_form_page3_cv_14c_page_3_notes_part_1", with: "Hello, note 1"

      select "Yes", from: "hub_update13614c_form_page3_paid_student_loan_interest"
      select "Yes", from: "hub_update13614c_form_page3_cv_1098e_cb"

      select "Yes", from: "hub_update13614c_form_page3_paid_dependent_care"
      select "Yes", from: "hub_update13614c_form_page3_cv_child_dependent_care_credit_cb"

      select "Yes", from: "hub_update13614c_form_page3_paid_retirement_contributions"
      select "Yes", from: "hub_update13614c_form_page3_contributed_to_ira"

      select "Yes", from: "hub_update13614c_form_page3_paid_school_supplies"
      select "Yes", from: "hub_update13614c_form_page3_cv_edu_expenses_deduction_cb"
      fill_in "hub_update13614c_form_page3_cv_edu_expenses_deduction_amt", with: '2814'

      select "Yes", from: "hub_update13614c_form_page3_paid_alimony"
      select "Yes", from: "hub_update13614c_form_page3_cv_paid_alimony_w_spouse_ssn_cb"
      # skip; getting 'SSN fields must include dashes in tests' and don't see a way to override.
      # fill_in "hub_update13614c_form_page3_cv_paid_alimony_w_spouse_ssn_amt", with: '2815'
      select "Yes", from: "hub_update13614c_form_page3_cv_alimony_income_adjustment_yn_cb"

      fill_in "hub_update13614c_form_page3_cv_14c_page_3_notes_part_2", with: "Hello, note 2"

      select "Yes", from: "hub_update13614c_form_page3_paid_post_secondary_educational_expenses"
      select "Yes", from: "hub_update13614c_form_page3_cv_taxable_scholarship_income_cb"
      select "Yes", from: "hub_update13614c_form_page3_cv_1098t_cb"
      select "Yes", from: "hub_update13614c_form_page3_cv_edu_credit_or_tuition_deduction_cb"

      select "Yes", from: "hub_update13614c_form_page3_sold_a_home"
      select "Yes", from: "hub_update13614c_form_page3_cv_1099s_cb"

      select "Yes", from: "hub_update13614c_form_page3_had_hsa"
      select "Yes", from: "hub_update13614c_form_page3_cv_hsa_contrib_cb"
      select "Yes", from: "hub_update13614c_form_page3_cv_hsa_distrib_cb"

      select "Yes", from: "hub_update13614c_form_page3_bought_marketplace_health_insurance"
      select "Yes", from: "hub_update13614c_form_page3_cv_1095a_cb"

      select "Yes", from: "hub_update13614c_form_page3_bought_energy_efficient_items"
      select "Yes", from: "hub_update13614c_form_page3_cv_energy_efficient_home_improv_credit_cb"

      select "Yes", from: "hub_update13614c_form_page3_had_debt_forgiven"
      select "Yes", from: "hub_update13614c_form_page3_cv_1099c_cb"

      select "Yes", from: "hub_update13614c_form_page3_had_disaster_loss"
      select "Yes", from: "hub_update13614c_form_page3_cv_1099a_cb"
      select "Yes", from: "hub_update13614c_form_page3_cv_disaster_relief_impacts_return_cb"

      select "Yes", from: "hub_update13614c_form_page3_had_tax_credit_disallowed"
      select "Yes", from: "hub_update13614c_form_page3_cv_eitc_ctc_aotc_hoh_disallowed_in_a_prev_yr_cb"
      fill_in "hub_update13614c_form_page3_tax_credit_disallowed_year", with: '2000'
      fill_in "hub_update13614c_form_page3_cv_tax_credit_disallowed_reason", with: 'a reason'

      select "Yes", from: "hub_update13614c_form_page3_received_irs_letter"
      select "Yes", from: "hub_update13614c_form_page3_cv_eligible_for_litc_referral_cb"

      select "Yes", from: "hub_update13614c_form_page3_made_estimated_tax_payments"
      select "Yes", from: "hub_update13614c_form_page3_cv_estimated_tax_payments_cb"
      fill_in "hub_update13614c_form_page3_cv_estimated_tax_payments_amt", with: "3000"
      select "Yes", from: "hub_update13614c_form_page3_cv_last_years_refund_applied_to_this_yr_cb"
      fill_in "hub_update13614c_form_page3_cv_last_years_refund_applied_to_this_yr_amt", with: "3001"
      select "Yes", from: "hub_update13614c_form_page3_cv_last_years_return_available_cb"

      fill_in "hub_update13614c_form_page3_cv_14c_page_3_notes_part_3", with: "Hello, note 3"

      click_on I18n.t("general.save")

      expect(page).to have_text I18n.t("hub.clients.edit_13614c_form_page3.title")
      expect(page).to have_text I18n.t("general.changes_saved")

      intake = client.intake.reload

      expect(intake.paid_mortgage_interest).to eq "yes"
      expect(intake.cv_1098_cb).to eq "yes"
      expect(intake.cv_1098_count).to eq 5

      expect(intake.paid_local_tax).to eq "yes"

      expect(intake.paid_medical_expenses).to eq "yes"
      expect(intake.cv_med_expense_standard_deduction_cb).to eq "yes"
      expect(intake.cv_med_expense_itemized_deduction_cb).to eq "yes"

      expect(intake.paid_charitable_contributions).to eq "yes"

      expect(intake.cv_14c_page_3_notes_part_1).to eq "Hello, note 1"

      expect(intake.paid_student_loan_interest).to eq "yes"
      expect(intake.cv_1098e_cb).to eq "yes"

      expect(intake.paid_dependent_care).to eq "yes"
      expect(intake.cv_child_dependent_care_credit_cb).to eq "yes"

      expect(intake.paid_retirement_contributions).to eq "yes"
      expect(intake.contributed_to_ira).to eq "yes"

      expect(intake.paid_school_supplies).to eq "yes"
      expect(intake.cv_edu_expenses_deduction_cb).to eq "yes"
      expect(intake.cv_edu_expenses_deduction_amt).to eq 2814

      expect(intake.paid_alimony).to eq "yes"
      expect(intake.cv_paid_alimony_w_spouse_ssn_cb).to eq "yes"
      # skip; getting 'SSN fields must include dashes in tests' and don't see a way to override.
      # expect(intake.cv_paid_alimony_w_spouse_ssn_amt).to eq 2815
      expect(intake.cv_alimony_income_adjustment_yn_cb).to eq "yes"

      expect(intake.cv_14c_page_3_notes_part_2).to eq "Hello, note 2"

      expect(intake.paid_post_secondary_educational_expenses).to eq "yes"
      expect(intake.cv_taxable_scholarship_income_cb).to eq "yes"
      expect(intake.cv_1098t_cb).to eq "yes"
      expect(intake.cv_edu_credit_or_tuition_deduction_cb).to eq "yes"

      expect(intake.sold_a_home).to eq "yes"
      expect(intake.cv_1099s_cb).to eq "yes"

      expect(intake.had_hsa).to eq "yes"
      expect(intake.cv_hsa_contrib_cb).to eq "yes"
      expect(intake.cv_hsa_distrib_cb).to eq "yes"

      expect(intake.bought_marketplace_health_insurance).to eq "yes"
      expect(intake.cv_1095a_cb).to eq "yes"

      expect(intake.bought_energy_efficient_items).to eq "yes"
      expect(intake.cv_energy_efficient_home_improv_credit_cb).to eq "yes"

      expect(intake.had_debt_forgiven).to eq "yes"
      expect(intake.cv_1099c_cb).to eq "yes"

      expect(intake.had_disaster_loss).to eq "yes"
      expect(intake.cv_1099a_cb).to eq "yes"
      expect(intake.cv_disaster_relief_impacts_return_cb).to eq "yes"

      expect(intake.had_tax_credit_disallowed).to eq "yes"
      expect(intake.cv_eitc_ctc_aotc_hoh_disallowed_in_a_prev_yr_cb).to eq "yes"
      expect(intake.tax_credit_disallowed_year).to eq 2000
      expect(intake.cv_tax_credit_disallowed_reason).to eq 'a reason'

      expect(intake.received_irs_letter).to eq "yes"
      expect(intake.cv_eligible_for_litc_referral_cb).to eq "yes"

      expect(intake.made_estimated_tax_payments).to eq "yes"
      expect(intake.cv_estimated_tax_payments_cb).to eq "yes"
      expect(intake.cv_estimated_tax_payments_amt).to eq 3000
      expect(intake.cv_last_years_refund_applied_to_this_yr_cb).to eq "yes"
      expect(intake.cv_last_years_refund_applied_to_this_yr_amt).to eq 3001
      expect(intake.cv_last_years_return_available_cb).to eq "yes"

      expect(intake.cv_14c_page_3_notes_part_3).to eq "Hello, note 3"
    end

    scenario "I can see and update the 13614c page 4 form" do
      visit hub_client_path(id: client.id)
      within ".client-profile" do
        click_on "Edit 13614-C"
      end

      within '.form_13614c-page-links', match: :first do
        click_on "4"
      end
      expect(page).to have_text "Optional Information"
      expect(page).to have_text "You are not required to answer these questions"

      select "Very well", from: "hub_update13614c_form_page4_demographic_english_conversation"
      select "Prefer not to answer", from: "hub_update13614c_form_page4_demographic_english_reading"
      select "Yes", from: "hub_update13614c_form_page4_demographic_disability"
      select "Prefer not to answer", from: "hub_update13614c_form_page4_demographic_veteran"

     within ".primary-demographic-race" do
        check "American Indian or Alaska Native"
        check "Asian"
        check "Black or African American"
        check "Hispanic or Latino"
        check "Middle Eastern or North African"
        # check "Native Hawaiian or Pacific Islander"
        check "White"
      end
      within ".spouse-demographic-race" do
        check "American Indian or Alaska Native"
        # check "Asian"
        check "Black or African American"
        check "Hispanic or Latino"
        check "Middle Eastern or North African"
        check "Native Hawaiian or Pacific Islander"
        check "White"
      end

      click_on I18n.t("general.save")

      expect(page).to have_text "Optional Information"
      expect(page).to have_text I18n.t("general.changes_saved")

      intake = client.intake.reload
      expect(intake.demographic_english_conversation).to eq "very_well"
      expect(intake.demographic_english_reading).to eq "prefer_not_to_answer"
      expect(intake.demographic_disability).to eq "yes"
      expect(intake.demographic_veteran).to eq "prefer_not_to_answer"

      expect(intake.demographic_primary_american_indian_alaska_native).to be_truthy
      expect(intake.demographic_primary_asian).to be_truthy
      expect(intake.demographic_primary_black_african_american).to be_truthy
      expect(intake.demographic_primary_hispanic_latino).to be_truthy
      expect(intake.demographic_primary_mena).to be_truthy
      expect(intake.demographic_primary_native_hawaiian_pacific_islander).to be_falsy
      expect(intake.demographic_primary_white).to be_truthy

      expect(intake.demographic_spouse_american_indian_alaska_native).to be_truthy
      expect(intake.demographic_spouse_asian).to be_falsy
      expect(intake.demographic_spouse_black_african_american).to be_truthy
      expect(intake.demographic_spouse_hispanic_latino).to be_truthy
      expect(intake.demographic_spouse_mena).to be_truthy
      expect(intake.demographic_spouse_native_hawaiian_pacific_islander).to be_truthy
      expect(intake.demographic_spouse_white).to be_truthy
    end

    # TODO reenable this after GYR1-603 / https://github.com/codeforamerica/vita-min/pull/5406 gets merged.
    xdescribe "demographic questions on page 4 work in tandem with other flags" do
      before do
        client.intake.update(
          demographic_questions_opt_in: 'no',
          demographic_spouse_native_hawaiian_pacific_islander: true, # somehow exists in the db even though demographic opt in is false
        )
      end

      it "does not write the answers to the PDF unless the client opted in during intake or the hub user has saved page4" do
        # generate pdf, prove spouse ethnicity is not filled in because demographic_questions_opt_in is false
        form_fields = PdfForms.new.get_fields(PdfFiller::F13614cPdf.new(client.intake).output_file)
        expect(form_fields.find { |field| field.name == "form1[0].page4[0].yourSpousesRaceEthnicity[0].hawaiianPacific[0]" }.value).to eq("Off")
        expect(form_fields.find { |field| field.name == "form1[0].page4[0].yourSpousesRaceEthnicity[0].blackAfricanAmerican[0]" }.value).to eq("Off")

        visit hub_client_path(id: client.id)
        within ".client-profile" do
          click_on "Edit 13614-C"
        end

        within '.form_13614c-page-links', match: :first do
          click_on "4"
        end

        within ".spouse-demographic-race" do
          uncheck "Native Hawaiian or Pacific Islander"
          check "Black or African American"
        end

        click_on I18n.t("general.save")

        # generate pdf, prove spouse ethnicity is filled in because demographic_questions_hub_edit is true
        form_fields = PdfForms.new.get_fields(PdfFiller::F13614cPdf.new(client.reload.intake).output_file)
        expect(form_fields.find { |field| field.name == "form1[0].page4[0].yourSpousesRaceEthnicity[0].hawaiianPacific[0]" }.value).to eq("Off")
        expect(form_fields.find { |field| field.name == "form1[0].page4[0].yourSpousesRaceEthnicity[0].blackAfricanAmerican[0]]" }.value).to eq("1")
      end
    end

    scenario 'I can see and update the 13614c page 5 form', js: true do
      visit hub_client_path(id: client.id)
      within '.client-profile' do
        click_on 'Edit 13614-C'
      end

      within '.form_13614c-page-links', match: :first do
        click_on '5'
      end
      header = 'Additional Notes/Comments'
      expect(page).to have_text header

      note = 'It was very late and everyone had left the café except an old man who sat in the shadow the leaves of the tree made against the electric light.'
      fill_in 'hub_update13614c_form_page5_additional_notes_comments', with: note

      click_on I18n.t('general.save')

      expect(page).to have_text header
      expect(page).to have_text I18n.t('general.changes_saved')

      intake = client.intake.reload
      expect(intake.additional_notes_comments).to eq note
    end
  end
end
