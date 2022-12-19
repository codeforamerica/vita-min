require "rails_helper"

RSpec.describe "a user editing a clients 13614c form" do
  around do |example|
    Timecop.freeze(DateTime.strptime('2021-03-04 5:10 PST', '%F %R %Z'))
    example.run
    Timecop.return
  end

  context "as an admin user" do
    let(:organization) { create(:organization, name: "Assigned Org") }
    let!(:new_site) { create(:site, name: "Other Site") }

    let(:user) { create :admin_user }
    let(:assigned_user) { create :user, role: create(:organization_lead_role, organization: organization) }
    let(:tax_return) { create :gyr_tax_return, assigned_user: assigned_user, filing_status: nil }
    let(:client) {
      create :client,
             vita_partner: organization,
             tax_returns: [tax_return],
             intake: create(:intake,
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
                            had_interest_income: "no",
                            had_local_tax_refund: "unsure",
                            paid_alimony: "yes",
                            had_self_employment_income: "no",
                            has_crypto_income: "unsure"
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
      within "#dependents-fields" do
        expect(find_field("hub_update13614c_form_page1[dependents_attributes][0][first_name]").value).to eq "Lara"

        fill_in "hub_update13614c_form_page1_dependents_attributes_0_first_name", with: "Laura"
        fill_in "hub_update13614c_form_page1_dependents_attributes_0_last_name", with: "Peaches"
        fill_in "hub_update13614c_form_page1_dependents_attributes_0_birth_date_month", with: "12"
        fill_in "hub_update13614c_form_page1_dependents_attributes_0_birth_date_day", with: "1"
        fill_in "hub_update13614c_form_page1_dependents_attributes_0_birth_date_year", with: "2008"
        select "9", from: "hub_update13614c_form_page1_dependents_attributes_0_months_in_home"
        select "Y", from: "hub_update13614c_form_page1_dependents_attributes_0_north_american_resident"
      end
      click_on 'Save'

      # Stay on current page upon save
      within(".flash--notice") do
        expect(page).to have_text "Changes saved"
      end

      expect(page).to have_text "Part I – Your Personal Information"
      expect(page).to have_field('First Name', with: 'Emily')
      expect(page).to have_text('Last client 13614-C update: Mar 4 5:10 AM')
      within "#dependents-fields" do
        expect(find_field("hub_update13614c_form_page1[dependents_attributes][0][first_name]").value).to eq "Laura"
      end
    end

    # TODO: investigate: test fails when whole file is run, passes alone??
    scenario "When I click to another page without saving, my progress is not saved and I get a confirmation dialogue before proceeding", js: true do
      visit hub_client_path(id: client.id)
      within ".client-profile" do
        click_on "Edit 13614-C"
      end

      within "#primary-info" do
        fill_in 'First Name', with: 'Bloop'
      end

      page.accept_alert I18n.t("general.confirm_exit_without_saving") do
        click_on "2", match: :first
      end

      expect(page).to have_text I18n.t("hub.clients.edit_13614c_form_page2.part_3_title")
      expect(client.intake.reload.primary_first_name).to eq "Colleen"
    end

    scenario "When I cancel from 13614c page 2, my progress is not saved and I get routed back to the client hub", js: true do
      visit hub_client_path(id: client.id)
      within ".client-profile" do
        click_on "Edit 13614-C"
      end

      page.accept_alert I18n.t("general.confirm_exit_without_saving") do
        click_on "2", match: :first
      end

      within "#income-fields" do
        select "Yes", from: "hub_update13614c_form_page2_had_wages"
      end

      page.dismiss_prompt 'Are you sure you want to do that?' do
        click_on I18n.t("general.cancel")
      end

      expect(page).to have_text I18n.t("hub.clients.edit_13614c_form_page2.part_3_title")

      page.accept_alert 'Are you sure you want to do that?' do
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

      page.accept_alert I18n.t("general.confirm_exit_without_saving") do
        click_on "2", match: :first
      end
      expect(page).to have_text I18n.t("hub.clients.edit_13614c_form_page2.title")

      expect(page).to have_text "Part III – Income – Last Year, Did You (or Your Spouse) Receive"

      within "#income-fields" do
        expect(find_field("hub_update13614c_form_page2[job_count]").value).to eq "2"

        select "Yes", from: "hub_update13614c_form_page2_had_wages"
        select "No", from: "hub_update13614c_form_page2_had_tips"
        select "Yes", from: "hub_update13614c_form_page2_had_interest_income"
        select "Yes", from: "hub_update13614c_form_page2_had_local_tax_refund"
        select "No", from: "hub_update13614c_form_page2_received_alimony"
        select "I don't know", from: "hub_update13614c_form_page2_had_self_employment_income"
        select "No", from: "hub_update13614c_form_page2_has_crypto_income"
        select "I don't know", from: "hub_update13614c_form_page2_had_asset_sale_income"
        select "No", from: "hub_update13614c_form_page2_had_disability_income"
        select "Yes", from: "hub_update13614c_form_page2_had_retirement_income"
        select "Yes", from: "hub_update13614c_form_page2_had_unemployment_income"
        select "No", from: "hub_update13614c_form_page2_had_social_security_income"
        select "No", from: "hub_update13614c_form_page2_had_rental_income"
        select "I don't know", from: "hub_update13614c_form_page2_had_other_income"
      end

      within "#expenses-fields" do
        select "Yes", from: "hub_update13614c_form_page2_paid_alimony"
        select "No", from: "hub_update13614c_form_page2_paid_retirement_contributions"
        select "Yes", from: "hub_update13614c_form_page2_paid_dependent_care"
        select "I don't know", from: "hub_update13614c_form_page2_paid_school_supplies"
        select "No", from: "hub_update13614c_form_page2_paid_student_loan_interest"
      end

      within "#life-events-fields" do
        select "Yes", from: "hub_update13614c_form_page2_had_hsa"
        select "No", from: "hub_update13614c_form_page2_had_debt_forgiven"
        select "No", from: "hub_update13614c_form_page2_adopted_child"
        select "I don't know", from: "hub_update13614c_form_page2_had_tax_credit_disallowed"
        select "No", from: "hub_update13614c_form_page2_bought_energy_efficient_items"
        select "No", from: "hub_update13614c_form_page2_received_homebuyer_credit"
        select "No", from: "hub_update13614c_form_page2_made_estimated_tax_payments"
      end

      click_on I18n.t("general.save")

      expect(page).to have_text I18n.t("hub.clients.edit_13614c_form_page2.title")
      expect(page).to have_text I18n.t("general.changes_saved")

      intake = client.intake.reload
      expect(intake.had_wages_yes?).to eq true
      expect(intake.had_tips_no?).to eq true
      expect(intake.had_interest_income_yes?).to eq true
      expect(intake.had_local_tax_refund_yes?).to eq true
      expect(intake.had_self_employment_income_unsure?).to eq true
      expect(intake.has_crypto_income).to eq false
      expect(intake.had_asset_sale_income_unsure?).to eq true
      expect(intake.had_disability_income_no?).to eq true
      expect(intake.had_retirement_income_yes?).to eq true
      expect(intake.had_unemployment_income_yes?).to eq true
      expect(intake.had_social_security_income_no?).to eq true
      expect(intake.had_rental_income_no?).to eq true
      expect(intake.had_other_income_unsure?).to eq true

      expect(intake.paid_alimony_yes?).to eq true
      expect(intake.paid_retirement_contributions_no?).to eq true
      expect(intake.paid_dependent_care_yes?).to eq true
      expect(intake.paid_school_supplies_unsure?).to eq true
      expect(intake.paid_student_loan_interest_no?).to eq true

      expect(intake.had_hsa_yes?).to eq true
      expect(intake.had_debt_forgiven_no?).to eq true
      expect(intake.adopted_child_no?).to eq true
      expect(intake.had_tax_credit_disallowed_unsure?).to eq true
      expect(intake.bought_energy_efficient_items_no?).to eq true
      expect(intake.received_homebuyer_credit_no?).to eq true
      expect(intake.made_estimated_tax_payments_no?).to eq true
    end
  end
end
