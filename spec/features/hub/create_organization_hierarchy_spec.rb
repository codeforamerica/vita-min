require "rails_helper"

RSpec.describe "create VITA organization hierarchy", :js do
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

      within "#organization-form" do
        fill_in "Name", with: "Oregano Org"
        select "Coati Coalition", from: "Coalition"
        click_on "Save"
      end
      expect(page).to have_selector("h1", text: "Oregano Org")

      # adding / removing zip codes
      within "#zip-code-routing-form" do
        fill_in "Zip code", with: "94606"
        click_on "Save"
        expect(page).to have_text "94606 Oakland, California"
        zip = VitaPartnerZipCode.find_by(zip_code: "94606")
        within "#zip-code-routing-rule-#{zip.id}" do
          page.accept_alert "Are you sure you want to delete 94606 from Oregano Org?" do
            click_on "Delete"
          end
        end
        expect(page).not_to have_text "94606 Oakland, California"
      end

      # adding / removing unique links
      within "#source-params-form" do
        fill_in "Unique link", with: "oregano"
        click_on "Save"
        expect(page).to have_text "oregano"
        sp = SourceParameter.find_by(code: "oregano")
        within "#source-param-#{sp.id}" do
          page.accept_alert "Are you sure you want to delete oregano from Oregano Org?" do
            click_on "Delete"
          end
        end
        expect(page).not_to have_text "oregano"
      end

      # Add a site to an organization
      click_on "Add site"
      fill_in "Name", with: "Llama Library"
      within "#site-form" do
        click_on "Save"
      end

      expect(page).to have_selector("h1", text: "Oregano Org")
      expect(page).to have_text("Llama Library")

      # Update the site
      click_on "Llama Library"
      within "#site-form" do
        fill_in "Name", with: "Lima Bean Library"
        click_on "Save"
      end

      expect(page).to have_selector("h1", text: "Lima Bean Library")

      # Navigate to the org
      click_on "Oregano Org"
      expect(page).to have_text("Lima Bean Library")

      # Go back to organization index
      click_on "All organizations"

      expect(page).to have_text("Oregano Org (1 site)")
    end
  end
end
