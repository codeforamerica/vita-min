require "rails_helper"

RSpec.feature "Change tax return status on a client" do
  context "As a beta tester" do
    let(:user) { create :user_with_membership, name: "Example Preparer"}
    let(:vita_partner) { user.memberships.first.vita_partner }
    let(:client) { create :client, vita_partner: vita_partner }
    let!(:intake) { create :intake, client: client }
    let!(:tax_return) { create :tax_return, year: 2019, client: client, status: "intake_in_progress" }

    before do
      login_as user
    end

    scenario "logged in user can change a status on a tax return" do
      visit case_management_client_path(id: client.id)
      expect(page).to have_select("tax_return_status", selected: "In progress")

      within "#tax-return-#{tax_return.id}" do
        select "Open", from: "tax_return_status"

        click_on "Update"
      end

      expect(current_path).to eq(edit_status_case_management_client_tax_return_path(id: tax_return.id, client_id: tax_return.client.id))
      expect(page).to have_select("tax_return_status", selected: "Open")

      click_on "Save"
      expect(current_path).to eq(case_management_client_messages_path(client_id: tax_return.client.id))
      expect(page).to have_select("tax_return_status", selected: "Open")

      click_on "Notes"
      expect(page).to have_text("Example Preparer updated 2019 tax return status from Intake/In progress to Intake/Open")
    end
  end
end
