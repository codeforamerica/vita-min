require "rails_helper"

RSpec.feature "Assign a user to a tax return", js: true do
  context "As an authenticated user" do
    let(:organization) { create :organization}
    let(:logged_in_user) { create :user, name: "Lucille 1", role: create(:organization_lead_role, organization: organization) }
    let!(:user_to_assign) { create :user, name: "Lucille 2", role: create(:organization_lead_role, organization: organization) }
    let(:client) { create :client, vita_partner: organization }
    let!(:intake) { create :intake, :with_contact_info, client: client, preferred_name: "Buster" }
    let!(:tax_return_to_assign) { create :tax_return, :intake_ready, year: 2019, client: client }

    before do
      login_as logged_in_user
    end

    scenario "logged in user can assign another user to a tax return" do
      visit hub_clients_path

      within "#tax-return-#{tax_return_to_assign.id}" do
        click_link "Assign"
        expect(page).to have_text "Assign to"
        expect(page).to have_text "Cancel"
        select "Lucille 2", from: "Assign to"
        click_on "Save"
      end

      expect(page).to have_selector(".selected", text: "All Clients")

      expect(page).to have_text "Assigned Buster's 2019 tax return to Lucille 2."

      within "#tax-return-#{tax_return_to_assign.id}" do
        expect(page).to have_text "Lucille 2"
      end

      click_on intake.preferred_name

      click_on "Notes"

      expect(page).to have_text "Lucille 1 assigned 2019 return to Lucille 2."
    end
  end
end
