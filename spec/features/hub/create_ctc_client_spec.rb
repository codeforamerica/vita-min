require "rails_helper"

RSpec.feature "Creating new drop off clients" do
  context "As an authenticated admin user" do
    let(:user) { create :admin_user }
    let!(:vita_partner) { create :vita_partner, name: "Brassica Asset Builders" }
    let!(:child_partner) { create :vita_partner, parent_organization: vita_partner, name: "Floret Financial Readiness" }
    before do
      login_as user
    end

    scenario "I can create a new CTC client", js: true do
      visit new_hub_ctc_client_path

      within("h1") do
        expect(page).to have_text "Add a new CTC client"
      end

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


      click_on "Send for prep"

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
  end
end
