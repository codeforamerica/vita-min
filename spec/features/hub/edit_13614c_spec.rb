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

    scenario "I can see and update the 13614c page 3 form" do
      visit hub_client_path(id: client.id)
      within ".client-profile" do
        click_on "Edit 13614-C"
      end

      within '.form_13614c-page-links', match: :first do
        click_on "3"
      end
      expect(page).to have_text I18n.t("hub.clients.edit_13614c_form_page3.title")

      expect(page).to have_text I18n.t("hub.clients.edit_13614c_form_page3.additional_info_title")

      # TODO add setup

      click_on I18n.t("general.save")

      expect(page).to have_text I18n.t("hub.clients.edit_13614c_form_page3.title")
      expect(page).to have_text I18n.t("general.changes_saved")

      intake = client.intake.reload

      # TODO expects
    end
  end
end
