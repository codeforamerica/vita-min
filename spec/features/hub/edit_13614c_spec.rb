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
        expect(find_field("hub_update13614c_form[dependents_attributes][0][first_name]").value).to eq "Lara"

        fill_in "hub_update13614c_form_dependents_attributes_0_first_name", with: "Laura"
        fill_in "hub_update13614c_form_dependents_attributes_0_last_name", with: "Peaches"
        fill_in "hub_update13614c_form_dependents_attributes_0_birth_date_month", with: "12"
        fill_in "hub_update13614c_form_dependents_attributes_0_birth_date_day", with: "1"
        fill_in "hub_update13614c_form_dependents_attributes_0_birth_date_year", with: "2008"
        select "9", from: "hub_update13614c_form_dependents_attributes_0_months_in_home"
        select "Y", from: "hub_update13614c_form_dependents_attributes_0_north_american_resident"
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
        expect(find_field("hub_update13614c_form[dependents_attributes][0][first_name]").value).to eq "Laura"
      end
    end

    scenario "I can see and update the 13614c page 2 form" do
      visit hub_client_path(id: client.id)
      within ".client-profile" do
        click_on "Edit 13614-C"
      end

      click_on "2"
      expect(page).to have_text I18n.t("hub.clients.edit_13614c_form_page2.title")

      expect(page).to have_text "Part III - Income - Last Year, Did You (or Your Spouse) Receive"

      within "#income-fields" do
        expect(find_field("hub_update13614c_form_page2[job_count]").value).to eq "2"
        # TODO: add more expectations for existing fields?

        select "Yes", from: "hub_update13614c_form_page2_had_wages"
        select "No", from: "hub_update13614c_form_page2_had_tips"
        select "Yes", from: "hub_update13614c_form_page2_had_interest_income"
        select "Yes", from: "hub_update13614c_form_page2_had_local_tax_refund"
        select "No", from: "hub_update13614c_form_page2_paid_alimony"
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
      end
      #
      # within "#life-events-fields" do
      #
      # end

      click_on I18n.t("general.save")

      expect(page).to have_text I18n.t("hub.clients.edit_13614c_form_page2.title")
      expect(page).to have_text I18n.t("general.changes_saved")

      # TODO: check database for correctly updated answers?
    end
  end
end
