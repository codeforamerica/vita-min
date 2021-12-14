require "rails_helper"

RSpec.feature "Creating new drop off clients" do
  context "As an authenticated admin user" do
    let(:user) { create :admin_user }
    let!(:vita_partner) { create :organization, name: "Brassica Asset Builders", processes_ctc: false }
    let!(:child_partner) { create :site, parent_organization: vita_partner, name: "Floret Financial Readiness", processes_ctc: true }
    before do
      login_as user
    end

    scenario "I can create a new CTC client", js: true do
      visit hub_clients_path
      click_on "Add CTC client"

      expect(page).to have_selector "h1", text: "Add a new CTC client"

      expect(page.find("#hub_create_ctc_client_form_vita_partner_id").all('option').collect(&:text)).to include "Floret Financial Readiness"
      expect(page.find("#hub_create_ctc_client_form_vita_partner_id").all('option').collect(&:text)).not_to include "Brassica Asset Builders"

      select "Floret Financial Readiness", from: "Assign to"

      fill_in "Preferred full name", with: "Colly Cauliflower"
      within "#primary-info" do
        fill_in "Legal first name", with: "Colleen"
        fill_in "Legal last name", with: "Cauliflower"
        fill_in "Email", with: "hello@cauliflower.com"
        fill_in "Cell phone number", with: "8324651680"
        select "Social Security Number (SSN)"
        fill_in "SSN/ITIN", with: "222-33-4444"
        fill_in "Re-enter SSN/ITIN", with: "222-33-4444"
        fill_in "IP PIN", with: "123456"
        check "Opt into email notifications"
        check "Opt into sms notifications"
        fill_in "hub_create_ctc_client_form_primary_birth_date_month", with: "08"
        fill_in "hub_create_ctc_client_form_primary_birth_date_day", with: "24"
        fill_in "hub_create_ctc_client_form_primary_birth_date_year", with: "1996"
        select "Mandarin", from: "Preferred language"
      end

      within "#address-fields" do
        fill_in "Street address", with: "123 Garden Ln"
        fill_in "City", with: "Brassicaville"
        select "California", from: "State"
        fill_in "ZIP code", with: "95032"
      end

      within "#filing-status-fields" do
        choose "Married filing jointly"
      end

      within "#dependents-fields" do
        click_on "Add dependent"
        fill_in "Legal first name", with: "Miranda"
        fill_in "Legal last name", with: "Mango"
        new_field_id = all(".dependent-form")[0].first("input")["id"].tr('^0-9', '')
        fill_in "hub_create_ctc_client_form_dependents_attributes_#{new_field_id}_birth_date_month", with: "12"
        fill_in "hub_create_ctc_client_form_dependents_attributes_#{new_field_id}_birth_date_day", with: "1"
        fill_in "hub_create_ctc_client_form_dependents_attributes_#{new_field_id}_birth_date_year", with: "2008"
        select "Daughter", from: "Relationship"
        select "Social Security Number (SSN)"
        fill_in "SSN/ATIN", with: "222-33-6666"
        fill_in "Re-enter SSN/ATIN", with: "222-33-6666"
        fill_in "IP PIN", with: "345678"
      end

      within "#spouse-info" do
        fill_in "Legal first name", with: "Peter"
        fill_in "Legal last name", with: "Pepper"
        select "IV", from: "Suffix"
        fill_in "Email", with: "spicypeter@pepper.com"
        select "Social Security Number (SSN)"
        fill_in "SSN/ITIN", with: "222-33-5555"
        fill_in "Re-enter SSN/ITIN", with: "222-33-5555"
        fill_in "IP PIN", with: "234567"
        fill_in "hub_create_ctc_client_form_spouse_birth_date_month", with: "01"
        fill_in "hub_create_ctc_client_form_spouse_birth_date_day", with: "11"
        fill_in "hub_create_ctc_client_form_spouse_birth_date_year", with: "1995"
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

      within "#identity-verification-fields" do
        fill_in "Name of navigator", with: "Terry Taxseason"
      end

      within "#photo-id-type-fields" do
        check "US Passport"
        check "Other State ID"
      end

      within "#taxpayer-id-type-fields" do
        check "Social Security card"
      end

      click_on I18n.t('general.save')

      expect(page).to have_text "Colleen Cauliflower"
      expect(page).to have_text "Colly Cauliflower"
      expect(page).to have_text "8/24/1996"
      expect(page).to have_text "Mandarin"
      expect(page).to have_text "Married filing jointly"
      expect(page).to have_text "hello@cauliflower.com"
      expect(page).to have_text "18324651680"
      expect(page).to have_text "123 Garden Ln"
      expect(page).to have_text "Brassicaville, CA 95032"
      within "#dependents-list" do
        expect(page).to have_text "Name: Miranda Mango"
        expect(page).to have_text "Relationship: Daughter"
        expect(page).to have_text "Date of Birth: 12/1/2008"
      end
      expect(page).to have_text "Peter Pepper"
      expect(page).to have_text "spicypeter@pepper.com"

      within ".client-bank-account-info" do
        click_on "View"
        expect(page).to have_content "Refund delivery method: Direct deposit"
      end

      expect(page).to have_text "Economic Impact Payment 1 received: $500"
      expect(page).to have_text "Economic Impact Payment 2 received: $500"
      expect(page).to have_text "Confidence: Sure"

      expect(page).to have_text "US Passport, Other State ID"

      expect(page).to have_text "Social Security card"

      expect(page).to have_text "Terry Taxseason"

      within ".tax-return-list" do
        expect(page).to have_text "#{TaxReturn.current_tax_year}"
      end

      within ".primary-ssn" do
        expect do
          click_on "View"
          expect(page).to have_text "222334444"
        end.to change(AccessLog, :count).by(1)
        expect(AccessLog.last.event_type).to eq "read_ssn_itin"
      end

      within ".primary-ip-pin" do
        click_on "View"
        expect(page).to have_text "123456"
      end

      within ".spouse-ssn" do
        expect do
          click_on "View"
          expect(page).to have_text "222335555"
        end.to change(AccessLog, :count).by(1)
        expect(AccessLog.last.event_type).to eq "read_ssn_itin"
      end

      within ".spouse-ip-pin" do
        click_on "View"
        expect(page).to have_text "234567"
      end

      within ".dependent_#{Dependent.last.id}-ssn" do
        expect do
          click_on "View"
          expect(page).to have_text "222336666"
        end.to change(AccessLog, :count).by(1)
        expect(AccessLog.last.event_type).to eq "read_ssn_itin"
      end

      within ".dependent_#{Dependent.last.id}-ip-pin" do
        click_on "View"
        expect(page).to have_text "345678"
      end

      visit hub_clients_path
      expect(page).to have_content("Colly Cauliflower")
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
        select "Social Security Number (SSN)"
        fill_in "SSN/ITIN", with: "222-33-4444"
        fill_in "Re-enter SSN/ITIN", with: "222-33-4444"
        fill_in "hub_create_ctc_client_form_primary_birth_date_month", with: "08"
        fill_in "hub_create_ctc_client_form_primary_birth_date_day", with: "24"
        fill_in "hub_create_ctc_client_form_primary_birth_date_year", with: "1996"
      end

      within "#filing-status-fields" do
        choose "Single"
      end

      within "#bank-account-fields" do
        choose "Check"
      end

      within "#photo-id-type-fields" do
        check "US Passport"
      end

      within "#taxpayer-id-type-fields" do
        check "Social Security card"
      end

      within "#identity-verification-fields" do
        fill_in "Name of navigator", with: "Terry Taxseason"
        check "I have checked and verified this client's identity."
      end

      expect do
        click_on I18n.t('hub.ctc_clients.new.save_and_add')
      end.to change(Client, :count).by(1)

      expect(page).to have_text(I18n.t('hub.clients.create.success_message'))
      expect(page.current_path).to eq(new_hub_ctc_client_path)
    end
  end
end
