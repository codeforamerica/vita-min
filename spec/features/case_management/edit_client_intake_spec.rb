require "rails_helper"

RSpec.describe "a user editing a clients intake fields" do
  context "as an admin user" do
    let(:user) { create :admin_user, vita_partner: create(:vita_partner) }
    let(:client) { create :client, vita_partner: user.memberships.first.vita_partner, intake: create(:intake, primary_first_name: "Colleen", primary_last_name: "Cauliflower") }
    before { login_as user }

    scenario "I can update available fields" do
      visit case_management_client_path(id: client.id)
      within ".client-profile" do
        click_on "Edit"
      end

      within "#primary-info" do
        expect(find_field("case_management_client_intake_form_primary_first_name").value).to eq "Colleen"
        expect(find_field("case_management_client_intake_form_primary_last_name").value).to eq "Cauliflower"
        fill_in "Preferred name", with: "Colly Cauliflower"
        select "Mandarin", from: "Preferred interview language"
        check "Married"
        check "Separated"
        fill_in "Separated year", with: "2017"
        check "Widowed"
        fill_in "Widowed year", with: "2015"
        check "Lived with spouse"
        check "Divorced"
        fill_in "Divorced year", with: "2018"

        check "Filing jointly"

        fill_in "Email", with: "hello@cauliflower.com"
        fill_in "Phone number", with: "5108675309"
        fill_in "Phone for texting", with: "8001234567"
        fill_in "Street address", with: "123 Garden Ln"
        fill_in "City", with: "Brassicaville"
        select "California", from: "State"
        fill_in "ZIP code", with: "95032"
        check "Opted into email notifications"
        check "Opted into sms notifications"
      end

      within "#spouse-info" do
        fill_in "Legal first name", with: "Peter"
        fill_in "Legal last name", with: "Pepper"
        fill_in "Email", with: "spicypeter@pepper.com"
      end
      click_on "Save"

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
      expect(page).to have_text "5108675309"
      expect(page).to have_text "8001234567"
      expect(page).to have_text "123 Garden Ln"
      expect(page).to have_text "Brassicaville, CA 95032"
      expect(page).to have_text "• Text message"
      expect(page).to have_text "• Email"
      expect(page).to have_text "Peter Pepper"
      expect(page).to have_text "spicypeter@pepper.com"
    end
  end
end
