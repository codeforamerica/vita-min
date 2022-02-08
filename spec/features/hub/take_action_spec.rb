require "rails_helper"

RSpec.feature "Change tax return status on a client" do
  context "As an authenticated user" do
    let(:organization) { create :organization }
    let(:user) { create :user, name: "Example Preparer", role: create(:organization_lead_role, organization: organization) }
    let(:client) { create :client, vita_partner: organization }
    let!(:intake) { create :intake, client: client, locale: "en", email_address: "client@example.com", phone_number: "+14155551212", sms_phone_number: "+14155551212", email_notification_opt_in: "yes", interview_timing_preference: "tomorrow!", sms_notification_opt_in: "yes" }
    let!(:tax_return) { create :tax_return, :intake_in_progress, year: 2019, client: client }
    let!(:other_tax_return) { create :tax_return, :intake_in_progress, year: 2018, client: client }

    before do
      login_as user
    end

    scenario "can changes status from any hub page, sends a message, and creates an internal note" do
      # One day, when switching the status causes a page reload, this test can expect a templated message.
      visit hub_client_notes_path(client_id: client.id)
      click_on "Take action"

      expect(current_path).to eq(edit_take_action_hub_client_path(id: tax_return.client))
      expect(page).to have_select("hub_take_action_form_state")
      select "Preparing", from: "Updated status"
      select "2019", from: "Filing year"

      expect(page).to have_select("hub_take_action_form_locale", selected: "English")
      choose "Text Message"
      fill_in "Send message", with: "Heads up! I am still working on it."
      fill_in "Add an internal note", with: "Leaving a note to the client"
      click_on "Send"
      expect(page).to have_text "Preparing"

      expect(current_path).to eq hub_client_path(id: client.id)
      click_on "Notes"
      expect(page).to have_text("Leaving a note to the client")
      click_on "Messages"
      expect(page).to have_text "(415) 555-1212"
      expect(page).to have_text "Heads up! I am still working on it."
    end

    scenario "can change a status on a tax return and send a templated message" do
      visit hub_client_path(id: client.id)
      expect(page).to have_select("tax_return[state]", selected: "Not ready")

      within "#tax-return-#{tax_return.id}" do
        select "Accepted"
        click_on "Update"
      end

      expect(current_path).to eq(edit_take_action_hub_client_path(id: tax_return.client))
      expect(page).to have_select("hub_take_action_form_tax_return_id", selected: "2019")
      expect(page).to have_select("hub_take_action_form_state", selected: "Accepted")
      expect(page).to have_select("hub_take_action_form_locale", selected: "English")

      expect(page).to have_text("Send message")
      expect(page).to have_text("Your #{tax_return.year} tax return has been accepted!")
      expect(page).to have_text("By clicking send, you will also update status, send a team note, and update followers.")

      click_on "Send"

      expect(current_path).to eq(hub_client_path(id: tax_return.client))
      within "#tax-return-#{tax_return.id}" do
        expect(page).to have_select("Status", selected: "Accepted")
      end

      click_on "Notes"
      expect(page).to have_text("Example Preparer updated 2019 tax return status from Intake/Not ready to Final steps/Accepted")
    end

    scenario "can cancel the updates and return to client's profile" do
      visit hub_client_path(id: client.id)
      expect(page).to have_select("tax_return[state]", selected: "Not ready")

      within "#tax-return-#{tax_return.id}" do
        select "Accepted"
        click_on "Update"
      end

      expect(current_path).to eq(edit_take_action_hub_client_path(id: tax_return.client))
      click_on "Cancel"

      expect(current_path).to eq(hub_client_path(id: client.id))
      expect(page).to have_select("tax_return[state]", selected: "Not ready")
    end

    context "for an online intake ctc tax return" do
      let!(:intake) { create :ctc_intake, client: client }
      let!(:tax_return) { create :tax_return, :intake_in_progress, year: 2019, client: client}

      it "cannot change the status" do
        visit hub_client_path(id: client.id)
        within '.tax-return-list' do
          expect(page).to have_content("Intake/Not ready")
        end
      end
    end
  end
end
