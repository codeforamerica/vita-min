require "rails_helper"

RSpec.describe "create VITA organization hierarchy" do
  context "as an admin user" do
    let(:admin_user) { create :admin_user }
    before { login_as admin_user }
    let(:coalition) { create :coalition, name: "Koala Koalition" }
    let!(:organization) { create :organization, name: "Orangutan Organization", coalition: coalition }

    scenario "create a new organization" do
      visit hub_user_profile_path
      click_on "Organizations"

      expect(page).to have_selector("h1", text: "Organizations")
      expect(page).to have_selector("h2", text: "Koala Koalition")
      expect(page).to have_selector("h3", text: "Orangutan Organization")

      return # ben plz move this return line
      click_on "New Organization"
      fill_in "Name", with: "Origami Organization"
      select "Koala Koalition", from: "Coalition"
      click_on "Save"

      expect(page).to have_selector("h3", text: "Origami Organization")
    end
  end
end
