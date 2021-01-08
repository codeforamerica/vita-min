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

    scenario "can return to the client list page" do
      visit hub_client_path(id: client.id)
      click_on("Return to all clients")

      expect(current_path).to eq(hub_clients_path)
    end
  end

  context "user without admin access" do

    let!(:user) { create :organization_lead_user }
    let!(:client) { create :client, vita_partner: user.role.organization, intake: create(:intake, :with_contact_info) }
    before do
      login_as user
    end

    scenario "can view and cannot update organization" do
      visit hub_client_path(id: client.id)
      within ".client-header__organization" do
        expect(page).to have_text client.vita_partner.name
        expect(page).not_to have_text "Edit"
      end
    end
  end

  skip "user without admin access, but is coalition lead for client organization" do
    # this test may not be entirely correct
    let(:coalition) { create :coalition }
    let(:user) { create :coalition_lead_user, role: create(:coalition_lead_role, coalition: coalition) }
    let(:client) { create :client, vita_partner: (create :vita_partner), intake: create(:intake, :with_contact_info) }
    let!(:coalition_member_organization) { create :vita_partner, coalition: coalition }
    before { login_as user }

    scenario "can view and update client organization" do
      visit hub_client_path(id: client.id)
      within ".client-header" do
        expect(page).to have_text client.vita_partner.name
        click_on "Edit"
      end
      expect(page.current_path).to eq edit_organization_hub_client_path(id: client.id)
      expect(page).to have_text "Edit Organization for #{client.preferred_name}"
      select coalition_member_organization.name, from: "Organization"
      click_on "Save"
      within ".client-header" do
        expect(page).to have_text coalition_member_organization.name
      end
    end
  end
end
