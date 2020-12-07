require "rails_helper"

RSpec.feature "Creating new drop off clients" do
  context "As an authenticated user" do
    let(:user) { create :user, vita_partner: vita_partner }
    let!(:vita_partner) { create :vita_partner, name: "Brassica Asset Builders" }
    let!(:child_partner) { create :vita_partner, parent_organization: vita_partner, name: "Floret Financial Readiness" }
    before do
      login_as user
    end

    scenario "I can create a new client" do
      visit hub_clients_path
      click_on "Add client"

      within("h1") do
        expect(page).to have_text "Add a new client"
      end

      expect(page).to have_text "Drop off"
      select "Floret Financial Readiness", from: "Assign to"

      fill_in "Preferred full name", with: "Colly Cauliflower"
      within "#primary-info" do
        fill_in "Legal first name", with: "Colleen"
        fill_in "Legal last name", with: "Cauliflower"
        fill_in "Email", with: "hello@cauliflower.com"
        fill_in "Phone number", with: "8324658840"
        fill_in "Phone for texting", with: "8324651680"
        fill_in "Street address", with: "123 Garden Ln"
        select "Texas", from: "State of residence"
        fill_in "City", with: "Brassicaville"
        select "California", from: "State"
        fill_in "ZIP code", with: "95032"
        check "Opt into email notifications"
        check "Opt into sms notifications"
        select "Mandarin", from: "Preferred language"
        check "Married"
        check "Separated"
        fill_in "Separated year", with: "2017"
        check "Widowed"
        fill_in "Widowed year", with: "2015"
        check "Lived with spouse"
        check "Divorced"
        fill_in "Divorced year", with: "2018"
        check "Filing jointly"
      end
      
      within "#spouse-info" do
        fill_in "Legal first name", with: "Peter"
        fill_in "Legal last name", with: "Pepper"
        fill_in "Email", with: "spicypeter@pepper.com"
      end

      # fields for tax return years
      check "2020"
      check "2019"
      check "2017"
      select "Basic", from: "hub_create_client_form_tax_returns_attributes_0_certification_level"
      select "Basic", from: "hub_create_client_form_tax_returns_attributes_1_certification_level"
      select "Basic", from: "hub_create_client_form_tax_returns_attributes_2_certification_level"
      select "Basic", from: "hub_create_client_form_tax_returns_attributes_3_certification_level"

      check "Opt into email notifications"
      check "Opt into sms notifications"

      # do we need notification preferences?

      click_on "Send for prep"

      expect(page).to have_text "Colleen Cauliflower"
      expect(page).to have_text "Colly Cauliflower"
      expect(page).to have_text "Mandarin"
      expect(page).to have_text "Married"
      expect(page).to have_text "Separated 2017"
      expect(page).to have_text "Widowed 2015"
      expect(page).to have_text "Lived with spouse"
      expect(page).to have_text "Divorced 2018"
      expect(page).to have_text "Filing jointly"
      expect(page).to have_text "hello@cauliflower.com"
      expect(page).to have_text "18324658840"
      expect(page).to have_text "18324651680"
      expect(page).to have_text "123 Garden Ln"
      expect(page).to have_text "Brassicaville, CA 95032"
      expect(page).to have_text "TX"
      expect(page).to have_text "• Text message"
      expect(page).to have_text "• Email"
      expect(page).to have_text "Peter Pepper"
      expect(page).to have_text "spicypeter@pepper.com"

      within ".tax-return-list" do
        expect(page).to have_text "2020"
        expect(page).to have_text "2019"
        expect(page).to have_text "2017"
      end
    end
  end
end
