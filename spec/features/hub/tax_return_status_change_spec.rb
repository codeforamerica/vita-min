require "rails_helper"

RSpec.feature "Change tax return status on a client" do
  context "As a beta tester" do
    let(:vita_partner) { create :vita_partner }
    let(:user) { create :user, name: "Example Preparer", vita_partner: vita_partner }
    let(:client) { create :client, vita_partner: vita_partner }
    let!(:intake) { create :intake, client: client, locale: "en", email_address: "client@example.com", email_notification_opt_in: "yes" }
    let!(:tax_return) { create :tax_return, year: 2019, client: client, status: "intake_in_progress" }
    let!(:other_tax_return) { create :tax_return, year: 2018, client: client, status: "intake_in_progress" }

    before do
      login_as user
    end

    scenario "logged in user can change a status on a tax return" do
      visit hub_client_path(id: client.id)
      expect(page).to have_select("tax_return_status", selected: "In progress")

      within "#tax-return-#{tax_return.id}" do
        select "Accepted", from: "tax_return_status"
        click_on "Update"
      end

      expect(current_path).to eq(edit_take_action_hub_client_path(id: tax_return.client))
      expect(page).to have_select("hub_take_action_form_tax_return_#{tax_return.id}__status", selected: "Accepted")
      expect(page).to have_select("hub_take_action_form_locale", selected: "English")

      expect(page).to have_text("Send message")
      expect(page).to have_text("Your federal and state returns have been accepted!")
      expect(page).to have_text("By clicking send, you will also update status, send a team note, and update followers.")

      click_on "Send"

      expect(current_path).to eq(hub_client_path(id: tax_return.client))
      within "#tax-return-#{tax_return.id}" do
        expect(page).to have_select("tax_return_status", selected: "Accepted")
      end

      click_on "Notes"
      expect(page).to have_text("Example Preparer updated 2019 tax return status from Intake/In progress to Filing completed/Accepted")
    end
  end
end
