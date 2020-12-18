require "rails_helper"

RSpec.feature "Assign a user to a tax return" do
  context "As an authenticated user" do
    let(:organization) { create :organization}
    let(:logged_in_user) { create :user, name: "Lucille 1" }
    let!(:user_to_assign) { create :user, name: "Lucille 2" }
    let(:client) { create :client, vita_partner: organization }
    let!(:intake) { create :intake, :with_contact_info, client: client }
    let!(:tax_return_to_assign) { create :tax_return, status: "intake_open", year: 2019, client: client }

    before do
      create :organization_lead_role, user: logged_in_user, organization: organization
      create :organization_lead_role, user: user_to_assign, organization: organization
      login_as logged_in_user
    end

    scenario "logged in user can assign another user to a tax return" do
      visit hub_clients_path

      within "#tax-return-#{tax_return_to_assign.id}" do
        click_on "Assign"
      end

      select "Lucille 2", from: "Assign to"
      click_on "Save"

      expect(page).to have_selector("h1", text: "All clients")
      within "#tax-return-#{tax_return_to_assign.id}" do
        expect(page).to have_text "Lucille 2"
      end

      click_on intake.preferred_name

      click_on "Notes"

      expect(page).to have_text "Lucille 1 assigned 2019 return to Lucille 2"
    end
  end
end
