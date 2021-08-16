require "rails_helper"

RSpec.describe "a user editing a clients intake fields" do
  context "as an admin user" do
    let(:organization) { create(:organization, name: "Assigned Org") }
    let!(:new_site) { create(:site, name: "Other Site") }

    let(:user) { create :admin_user }
    let!(:client) {
      create :client,
             vita_partner: organization,
             tax_returns: [create(:tax_return, filing_status: "married_filing_jointly")],
             intake: create(:ctc_intake,
                            email_address: "colleen@example.com",
                            filing_joint: "yes",
                            primary_first_name: "Colleen",
                            primary_last_name: "Cauliflower",
                            phone_number: "+14404093500",
                            state_of_residence: "CA",
                            preferred_name: "Colleen Cauliflower",
                            email_notification_opt_in: "yes",
                            timezone: "America/Chicago",
                            eip1_and_2_amount_received_confidence: "sure",
                            eip1_amount_received: 900,
                            dependents: [
                              create(:dependent, first_name: "Lara", last_name: "Legume", birth_date: "2007-03-06", ssn: "123456789"),
                            ])
    }

    before { login_as user }

    scenario "I can update available fields", js: true do
      expect(client.intake.is_ctc?).to be true
      visit hub_client_path(id: client.id)
      within ".client-profile" do
        click_on "Edit"
      end

      within "#primary-info" do
        fill_in "Preferred full name", with: "Bennet Basil"
      end

      click_on "Cancel"

      expect(page).to have_text "Colleen Cauliflower"
      expect(page).not_to have_text "Bennet Basil"

      within ".client-profile" do
        click_on "Edit"
      end

      within "#primary-info" do
        expect(find_field("hub_update_ctc_client_form_primary_first_name").value).to eq "Colleen"
        expect(find_field("hub_update_ctc_client_form_primary_last_name").value).to eq "Cauliflower"
        fill_in "Preferred full name", with: "Colly Cauliflower"
        fill_in "Email", with: "hello@cauliflower.com"
        check "Opt into email notifications"
        fill_in "Cell phone number", with: "500-555-0006"
        check "Opt into sms notifications"
        fill_in "SSN/ITIN", with: "111-22-4444"
        fill_in "Re-enter SSN/ITIN", with: "111-22-4444"
        fill_in "hub_update_ctc_client_form_primary_birth_date_month", with: "08"
        fill_in "hub_update_ctc_client_form_primary_birth_date_day", with: "24"
        fill_in "hub_update_ctc_client_form_primary_birth_date_year", with: "1996"
      end

      within "#dependents-fields" do
        fill_in "Legal first name", with: "Laura"
        expect(find_field("hub_update_ctc_client_form[dependents_attributes][0][first_name]").value).to eq "Laura"
        fill_in "Legal last name", with: "Peaches"
        select "December", from: "Month"
        select "1", from: "Day"
        select "2008", from: "Year"
      end

      within "#navigator-fields" do
        check "General"
        check "Incarcerated/reentry"
        check "Unhoused"
      end

      within "#address-fields" do
        fill_in "Street address", with: "123 Garden Ln"
        fill_in "City", with: "Brassicaville"
        select "California", from: "State"
        fill_in "ZIP code", with: "95032"
      end

      within "#recovery-rebate-credit-fields" do
        fill_in "Economic Impact Payment 1 received", with: "1200"
        fill_in "Economic Impact Payment 2 received", with: "1300"
        select "Sure", from: "hub_update_ctc_client_form_eip1_and_2_amount_received_confidence"
      end

      within "#spouse-info" do
        fill_in "Legal first name", with: "Peter"
        fill_in "Legal last name", with: "Pepper"
        fill_in "Email", with: "spicypeter@pepper.com"
        fill_in "SSN/ITIN", with: "111-22-3333"
        fill_in "Re-enter SSN/ITIN", with: "111-22-3333"
        fill_in "hub_update_ctc_client_form_spouse_birth_date_month", with: "10"
        fill_in "hub_update_ctc_client_form_spouse_birth_date_day", with: "24"
        fill_in "hub_update_ctc_client_form_spouse_birth_date_year", with: "1996"
      end

      click_on "Save"

      expect(page).to have_text "Colleen Cauliflower"
      expect(page).to have_text "Colly Cauliflower"
      expect(page).to have_text "Married filing jointly"
      expect(page).to have_text "Dependents: 1", normalize_ws: true
      within "#dependents-list" do
        expect(page).to have_text "Laura Peaches"
        expect(page).to have_text "12/1/2008"
      end
      expect(page).to have_text "Navigator type"
      expect(page).to have_text "General, Incarcerated/reentry, Unhoused"
      expect(page).to have_text "hello@cauliflower.com"
      expect(page).to have_text "+14404093500"
      expect(page).to have_text "+15005550006"
      expect(page).to have_text "123 Garden Ln"
      expect(page).to have_text "Brassicaville, CA 95032"
      expect(page).to have_text "Peter Pepper"
      expect(page).to have_text "spicypeter@pepper.com"
      within ".primary-ssn" do
        expect do
          click_on "View"
          expect(page).to have_text "111224444"
        end.to change(AccessLog, :count).by(1)
        expect(AccessLog.last.event_type).to eq "read_ssn_itin"
      end

      within ".spouse-ssn" do
        expect do
          click_on "View"
          expect(page).to have_text "111223333"
        end.to change(AccessLog, :count).by(1)
        expect(AccessLog.last.event_type).to eq "read_ssn_itin"
      end

      within ".client-recovery-rebate-credit-amount" do
        expect(page).to have_text "Economic Impact Payment 1 received: $1200"
        expect(page).to have_text "Economic Impact Payment 2 received: $1300"
        expect(page).to have_text "Confidence: Sure"
      end
    end
  end

  describe "ctc intakes" do
    context "as an admin user" do
      let(:user) { create :admin_user }

      before do
        # Create a CTC intake in a realistic way, then clear cookies
        allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
        complete_intake_through_code_verification
        allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(false)

        Capybara.current_session.reset!
      end

      it "can see clients created through CTC intake with their current status" do
        new_client = Client.last

        login_as user

        visit hub_clients_path

        within ".client-table" do
          click_on new_client.intake.preferred_name
        end

        within ".tax-return-list" do
          expect(page).to have_text "2020"
          expect(page).to have_text I18n.t('hub.tax_returns.status.intake_in_progress')
        end
      end
    end
  end
end
