require "rails_helper"

RSpec.describe "create VITA organization hierarchy", :js do
  context "as an admin user" do
    let(:admin_user) { create :admin_user }
    before { login_as admin_user }
    let(:koala_coalition) { create :coalition, name: "Koala Koalition" }
    let!(:coati_coalition) { create :coalition, name: "Coati Coalition" } # https://en.wikipedia.org/wiki/Coati
    let!(:organization) { create :organization, name: "Orangutan Organization", coalition: koala_coalition }

    before do
      create :state_routing_target, target: koala_coalition, state_abbreviation: "AL"
      create :state_routing_target, target: coati_coalition, state_abbreviation: "CA"
      create :state_routing_target, target: coati_coalition, state_abbreviation: "WA"
    end

    scenario "create a new organization in a coalition" do
      visit hub_tools_path
      click_on "Orgs"

      expect(page).to have_selector("h1", text: "Organization List")
      within "#alabama" do
        expect(page).to have_selector("h2", text: "Alabama")
        expect(page).to have_selector("li", text: "Koala Koalition")
        expect(page).to have_selector("li", text: "Orangutan Organization")
      end

      # create a new organization in a coalition
      click_on "Add new organization"
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
        check "Accepts ITIN applicants"
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

      within "#washington" do
        expect(page).to have_text("Oregano Org")
      end
      within "#california" do
        expect(page).to have_text("Oregano Org")
      end
    end

    scenario "create a new independent organization" do
      visit hub_tools_path
      click_on "Orgs"

      click_on "Add new organization"
      fill_in "Name", with: "Independent Wombat Organization"
      check "This organization is not part of a coalition"
      fill_in_tagify ".state-select", "California"
      click_on "Save"

      # Validate that the state saved
      click_on "Independent Wombat Organization"
      expect(page).to have_text("California")
      expect(page).not_to have_text("Ohio")
    end
  end
end
