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
        check "Flag"
        expect(page).to have_field("toggle-flag", checked: true)
        uncheck "Flag"
        expect(page).to have_field("toggle-flag", checked: false)
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
        click_on "BAS"
        select "Foreign Student", from: "Certification"
        click_button("button")
        expect(page).to have_text("FS")
        expect(page).not_to have_css(".tax-return-inline-form")
      end
    end
  end

  context "user without admin access, but is coalition lead for client organization" do
    let(:coalition) { create :coalition }
    let(:user) { create :coalition_lead_user, role: create(:coalition_lead_role, coalition: coalition) }
    let(:first_org) { create :organization, coalition: coalition }
    let(:client) { create :client, vita_partner: first_org, intake: create(:intake, :with_contact_info, email_address: "fizzy_pop@example.com") }
    let!(:intake_with_duplicate_email) { create :intake, email_address: "fizzy_pop@example.com", client: create(:client_with_status, vita_partner: first_org, status: "intake_ready") }
    let!(:ctc_intake_with_duplicate_email) { create :ctc_intake, email_address: "fizzy_pop@example.com", client: create(:client_with_status, vita_partner: first_org, status: "intake_ready") }
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

    scenario "can view potential duplicate intakes" do
      visit hub_client_path(id: client.id)
      expect(page).to have_text "fizzy_pop@example.com"

      within ".client-header" do
        expect(page).to have_text "Potential duplicates detected"
        expect(page).to have_text "CTC: ##{ctc_intake_with_duplicate_email.client.id}"
        expect(page).to have_text "GYR: ##{intake_with_duplicate_email.client.id}"
        click_on "##{intake_with_duplicate_email.client.id}"
      end

      expect(page.current_path).to eq hub_client_path(id: intake_with_duplicate_email.client.id)
      expect(page).to have_text "fizzy_pop@example.com"
    end
  end
end
