require "rails_helper"

RSpec.feature "Creating new drop off clients" do
  context "As an authenticated admin user" do
    let(:user) { create :admin_user }
    let!(:vita_partner) { create :vita_partner, name: "Brassica Asset Builders", processes_ctc: false }
    let!(:child_partner) { create :vita_partner, parent_organization: vita_partner, name: "Floret Financial Readiness", processes_ctc: true }
    before do
      login_as user
    end

    scenario "I can create a new CTC client", js: true do
      visit new_hub_ctc_client_path

      within("h1") do
        expect(page).to have_text "Add a new CTC client"
      end

      expect(page.find("#hub_create_ctc_client_form_vita_partner_id").all('option').collect(&:text)).to include "Floret Financial Readiness"
      expect(page.find("#hub_create_ctc_client_form_vita_partner_id").all('option').collect(&:text)).not_to include "Brassica Asset Builders"

      select "Floret Financial Readiness", from: "Assign to"

      fill_in "Preferred full name", with: "Colly Cauliflower"
      within "#primary-info" do
        fill_in "Legal first name", with: "Colleen"
        fill_in "Legal last name", with: "Cauliflower"
        fill_in "Email", with: "hello@cauliflower.com"
        fill_in "Cell phone number", with: "8324651680"
        fill_in "Last 4 of SSN/ITIN", with: "4444"
        check "Opt into email notifications"
        check "Opt into sms notifications"
        select "Mandarin", from: "Preferred language"
      end

      within "#address-fields" do
        fill_in "Street address", with: "123 Garden Ln"
        select "Texas", from: "State of residence"
        fill_in "City", with: "Brassicaville"
        select "California", from: "State"
        fill_in "ZIP code", with: "95032"
      end

      within "#filing-status-fields" do
        choose "Married filing jointly"
        fill_in "Filing status notes (optional)", with: "Got married in 2020!"
      end

      within "#dependents-fields" do
        click_on "Add dependent"
        fill_in "Legal first name", with: "Miranda"
        fill_in "Legal last name", with: "Mango"
        select "December", from: "Month"
        select "1", from: "Day"
        select "2008", from: "Year"
        select "Child", from: "Relationship"
      end

      within "#spouse-info" do
        fill_in "Legal first name", with: "Peter"
        fill_in "Legal last name", with: "Pepper"
        fill_in "Email", with: "spicypeter@pepper.com"
      end

      within "#recovery-rebate-credit-fields" do
        fill_in "Economic Impact Payment 1", with: "$500"
        fill_in "Economic Impact Payment 2", with: "$500"
        select "Sure", from: "How confident in this amount?"
      end

      within "#bank-account-fields" do
        choose "Check"
        expect(find_field("Bank name", visible: :hidden)).to be_present
        choose "Direct Deposit"
        fill_in "Bank name", with: "Bank of America"
        select "Checking", from: "Account type"
        fill_in "Routing number", with: "123456789"
        fill_in "Confirm routing number", with: "123456789"
        fill_in "Account number", with: "2345678901"
        fill_in "Confirm account number", with: "2345678901"
      end

      click_on I18n.t('general.save')

      expect(page).to have_text "Colleen Cauliflower"
      expect(page).to have_text "Colly Cauliflower"
      expect(page).to have_text "Mandarin"
      expect(page).to have_text "Married filing jointly"
      expect(page).to have_text "hello@cauliflower.com"
      expect(page).to have_text "18324651680"
      expect(page).to have_text "123 Garden Ln"
      expect(page).to have_text "Brassicaville, CA 95032"
      within "#dependents-list" do
        expect(page).to have_text "Miranda Mango, Child"
        expect(page).to have_text "12/1/2008"
      end
      expect(page).to have_text "TX"
      expect(page).to have_text "Peter Pepper"
      expect(page).to have_text "spicypeter@pepper.com"

      within ".client-bank-account-info" do
        click_on "View"
        expect(page).to have_content "Refund delivery method: Direct deposit"
      end

      expect(page).to have_text "Economic Impact Payment 1 received: $500"
      expect(page).to have_text "Economic Impact Payment 2 received: $500"
      expect(page).to have_text "Confidence: Sure"

      within ".tax-return-list" do
        expect(page).to have_text "2020"
      end

      within ".last-four-ssn" do
        expect do
          click_on "View"
          expect(page).to have_text "4444"
        end.to change(AccessLog, :count).by(1)
        expect(AccessLog.last.event_type).to eq "read_ssn_itin"
      end
    end

    scenario "I can create multiple CTC clients, one after another" do
      visit new_hub_ctc_client_path

      select "Floret Financial Readiness", from: "Assign to"

      fill_in "Preferred full name", with: "Colly Cauliflower"
      within "#primary-info" do
        fill_in "Legal first name", with: "Colleen"
        fill_in "Legal last name", with: "Cauliflower"
        fill_in "Email", with: "hello@cauliflower.com"
        check "Opt into email notifications"
        select "Mandarin", from: "Preferred language"
      end

      within "#filing-status-fields" do
        choose "Single"
      end

      within "#address-fields" do
        select "Texas", from: "State of residence"
      end

      within "#bank-account-fields" do
        fill_in "Bank name", with: "Bank of America"
        select "Checking", from: "Account type"
        fill_in "Routing number", with: "123456789"
        fill_in "Confirm routing number", with: "123456789"
        fill_in "Account number", with: "2345678901"
        fill_in "Confirm account number", with: "2345678901"
      end

      expect do
        click_on I18n.t('hub.ctc_clients.new.save_and_add')
      end.to change(Client, :count).by(1)

      expect(page).to have_text(I18n.t('hub.clients.create.success_message'))
      expect(page.current_path).to eq(new_hub_ctc_client_path)
    end
  end
end
