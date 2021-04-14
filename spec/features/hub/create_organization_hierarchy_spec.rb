require "rails_helper"

RSpec.describe "create VITA organization hierarchy" do
  context "as an admin user" do
    let(:admin_user) { create :admin_user }
    before { login_as admin_user }
    let(:coalition) { create :coalition, name: "Koala Koalition" }
    let!(:other_coalition) { create :coalition, name: "Coati Coalition" } # https://en.wikipedia.org/wiki/Coati
    let!(:organization) { create :organization, name: "Orangutan Organization", coalition: coalition }

    scenario "create a new organization" do
      visit hub_user_profile_path
      click_on "Organizations"

      expect(page).to have_selector("h1", text: "Organizations")
      expect(page).to have_selector("h2", text: "Koala Koalition")
      expect(page).to have_selector("li", text: "Orangutan Organization")

      # create a new organization
      click_on "New Organization"
      fill_in "Name", with: "Origami Organization"
      select "Koala Koalition", from: "Coalition"
      click_on "Save"

      # update the organization
      click_on "Origami Organization"
      expect(page).to have_text "0 active clients"

      expect(page).to have_text("No sites")

      fill_in "Name", with: "Oregano Org"
      select "Coati Coalition", from: "Coalition"
      click_on "Save"
      expect(page).to have_selector("h1", text: "Oregano Org")

      # Add a site to an organization
      click_on "Add site"
      fill_in "Name", with: "Llama Library"
      click_on "Save"

      expect(page).to have_selector("h1", text: "Oregano Org")
      expect(page).to have_text("Llama Library")

      # Update the site
      click_on "Llama Library"
      fill_in "Name", with: "Lima Bean Library"
      fill_in "Additional unique link", with: "limabean"
      click_on "Save"
      expect(page).to have_selector("h1", text: "Lima Bean Library")
      expect(page).to have_selector("input[value='limabean']")

      # Navigate to the org
      click_on "Oregano Org"
      expect(page).to have_text("Lima Bean Library")

      # Go back to organization index
      click_on "All organizations"

      expect(page).to have_text("Oregano Org (1 site)")
    end
  end
end
