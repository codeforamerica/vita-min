require "rails_helper"

RSpec.describe "a user viewing a client" do
  context "as an admin user" do
    let(:user) { create :admin_user }
    let(:client) { create :client, vita_partner: (create :vita_partner), intake: create(:intake, :with_contact_info), tax_returns: [create(:tax_return, certification_level: "advanced")] }
    let(:tax_return) { client.tax_returns.first }
    let!(:other_vita_partner) { create :vita_partner, name: "Tax Help Test" }
    before do
      login_as user
    end

    scenario "can view and update client organization" do
      visit hub_client_path(id: client.id)
      within ".client-header" do
        expect(page).to have_text client.vita_partner.name
        click_on "Edit"
      end
      expect(page.current_path).to eq edit_organization_hub_client_path(id: client.id)
      expect(page).to have_text "Edit Organization for #{client.preferred_name}"
      select other_vita_partner.name, from: "Organization"
      click_on "Save"
      within ".client-header" do
        expect(page).to have_text other_vita_partner.name
      end
    end

    scenario "can view and update tax return certification type" do
      visit hub_client_path(id: client.id)
      within "#tax-return-#{tax_return.id}" do
        expect(page).to have_text("ADV")
        expect(page).not_to have_css(".tax-return-inline-form")
        # change from advanced to basic
        click_on("ADV")
        expect(page).to have_css(".tax-return-inline-form")
        select "Basic", from: "Certification"
        click_button("button")
        expect(page).to have_text("BAS")
        expect(page).not_to have_css(".tax-return-inline-form")

        # change from basic to basic hsa
        click_on("BAS")
        check "is_hsa"
        click_button("button")
        expect(page).to have_text("BAS | HSA")
      end
    end

    context "navigation bar" do
      scenario "returns to the client search page" do
        visit hub_client_path(id: client.id)
        click_on("Search Clients")

        expect(current_path).to eq(search_hub_clients_path)
      end
    end
  end

  context "user without admin access, but is coalition lead for client organization" do
    let(:coalition) { create :coalition }
    let(:user) { create :coalition_lead_user, role: create(:coalition_lead_role, coalition: coalition) }
    let(:first_org) { create :organization, coalition: coalition }
    let(:client) { create :client, vita_partner: first_org, intake: create(:intake, :with_contact_info) }
    let!(:second_org) { create :organization, coalition: coalition }
    before { login_as user }

    context "navigation bar" do
      scenario "returns to all clients" do
        visit hub_client_path(id: client.id)
        click_on("All Clients")

        expect(current_path).to eq(hub_clients_path)
      end

      scenario "returns to user's profile" do
        visit hub_client_path(id: client.id)
        click_on("My Profile")

        expect(current_path).to eq(hub_user_profile_path)
      end

      scenario "returns to user's clients" do
        visit hub_client_path(id: client.id)
        click_on("My Clients")

        expect(current_path).to eq(hub_root_path)
      end
    end

    scenario "can view and update client organization" do
      visit hub_client_path(id: client.id)
      within ".client-header" do
        expect(page).to have_text client.vita_partner.name
        click_on "Edit"
      end
      expect(page.current_path).to eq edit_organization_hub_client_path(id: client.id)
      expect(page).to have_text "Edit Organization for #{client.preferred_name}"
      select second_org.name, from: "Organization"
      click_on "Save"
      within ".client-header" do
        expect(page).to have_text second_org.name
      end
    end
  end
end
