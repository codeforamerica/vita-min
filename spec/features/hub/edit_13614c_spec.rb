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

    scenario "I can see and update the 13614c page 2 form" do
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

      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page3.fields.q1_receive_written_communication")
      fill_in I18n.t("hub.clients.edit_13614c_form_page3.fields.q1_preferred_written_language"), with: "Chinese"
      select "You", from: I18n.t("hub.clients.edit_13614c_form_page3.fields.q2_presidential_campaign_fund")

      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page3.fields.q3_refund_payment_method_direct_deposit")
      select "No", from: I18n.t("hub.clients.edit_13614c_form_page3.fields.q3_refund_payment_method_savings_bond")
      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page3.fields.q3_refund_payment_method_split")

      select "No", from: I18n.t("hub.clients.edit_13614c_form_page3.fields.q4_pay_due_balance_directly")

      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page3.fields.q5_federal_disaster_area")
      fill_in I18n.t("hub.clients.edit_13614c_form_page3.fields.q5_federal_disaster_area_where"), with: "Paradise"

      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page3.fields.q6_letter_from_irs")
      select "No", from: I18n.t("hub.clients.edit_13614c_form_page3.fields.q7_register_to_vote")

      # Deliberately don't fill in the conversational language question
      select "Well", from: I18n.t("hub.clients.edit_13614c_form_page3.fields.q9_read_english")

      select "No", from: I18n.t("hub.clients.edit_13614c_form_page3.fields.q10_household_disability")
      select "Yes", from: I18n.t("hub.clients.edit_13614c_form_page3.fields.q11_veteran")

      within ".primary-demographic-race" do
        check "Asian"
        check "White"
      end
      within ".spouse-demographic-race" do
        check "Black or African American"
      end

      select "Not Hispanic or Latino", from: I18n.t("hub.clients.edit_13614c_form_page3.fields.q14_primary_ethnicity")
      select "Hispanic or Latino", from: I18n.t("hub.clients.edit_13614c_form_page3.fields.q15_spouse_ethnicity")

      click_on I18n.t("general.save")

      expect(page).to have_text I18n.t("hub.clients.edit_13614c_form_page3.title")
      expect(page).to have_text I18n.t("general.changes_saved")

      intake = client.intake.reload
      expect(intake.receive_written_communication).to eq "yes"
      expect(intake.preferred_written_language).to eq "Chinese"
      expect(intake.presidential_campaign_fund_donation).to eq "primary"
      expect(intake.refund_payment_method).to eq "direct_deposit"
      expect(intake.savings_purchase_bond).to eq "no"
      expect(intake.savings_split_refund).to eq "yes"
      expect(intake.balance_pay_from_bank).to eq "no"
      expect(intake.had_disaster_loss).to eq "yes"
      expect(intake.had_disaster_loss_where).to eq "Paradise"
      expect(intake.received_irs_letter).to eq "yes"
      expect(intake.register_to_vote).to eq "no"
      expect(intake.demographic_english_conversation).to eq "unfilled"
      expect(intake.demographic_english_reading).to eq "well"
      expect(intake.demographic_disability).to eq "no"
      expect(intake.demographic_veteran).to eq "yes"
      expect(intake.demographic_primary_asian).to be_truthy
      expect(intake.demographic_primary_black_african_american).to be_falsey
      expect(intake.demographic_primary_white).to be_truthy
      expect(intake.demographic_spouse_black_african_american).to be_truthy
      expect(intake.demographic_primary_ethnicity).to eq "not_hispanic_latino"
      expect(intake.demographic_spouse_ethnicity).to eq "hispanic_latino"
    end

    describe "demographic questions on page 3" do
      before do
        client.intake.update(
          demographic_questions_opt_in: 'no',
          demographic_spouse_native_hawaiian_pacific_islander: true, # somehow exists in the db even though demographic opt in is false
        )
      end

      # TODO reenable for TY2024
      xit "does not write the answers to the PDF unless the client opted in during intake or the hub user has saved page3" do
        # generate pdf, prove spouse ethnicity is not filled in because demographic_questions_opt_in is false
        form_fields = PdfForms.new.get_fields(PdfFiller::F13614cPdf.new(client.intake).output_file)
        expect(form_fields.find { |field| field.name == "form1[0].page3[0].q13[0].nativeHawaiian[0]" }.value).to eq("Off")
        expect(form_fields.find { |field| field.name == "form1[0].page3[0].q13[0].blackAfrican[0]" }.value).to eq("Off")

        visit hub_client_path(id: client.id)
        within ".client-profile" do
          click_on "Edit 13614-C"
        end

        within '.form_13614c-page-links', match: :first do
          click_on "3"
        end

        within ".spouse-demographic-race" do
          uncheck "Native Hawaiian or other Pacific Islander"
          check "Black or African American"
        end

        click_on I18n.t("general.save")

        # generate pdf, prove spouse ethnicity is filled in because demographic_questions_hub_edit is true
        form_fields = PdfForms.new.get_fields(PdfFiller::F13614cPdf.new(client.reload.intake).output_file)
        expect(form_fields.find { |field| field.name == "form1[0].page3[0].q13[0].nativeHawaiian[0]" }.value).to eq("")
        expect(form_fields.find { |field| field.name == "form1[0].page3[0].q13[0].blackAfrican[0]" }.value).to eq("1")
      end
    end
  end
end
