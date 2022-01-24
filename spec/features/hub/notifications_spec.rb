require "rails_helper"

RSpec.feature "View user notifications" do
  context "As an authenticated user" do
    let!(:notification) { create :user_notification, read: false, created_at: DateTime.new(2021, 3, 15), user: user, notifiable: tax_return_assignment }
    let!(:note_notification) { create :user_notification, created_at: DateTime.new(2021, 3,14), user: user, notifiable: note }

    let(:intake) { create(:intake, preferred_name: "Jenny Odell") }
    let(:client) { create :client, intake: intake }
    let(:tax_return_assignment) { create :tax_return_assignment, tax_return: tax_return, assigner: user_who_assigned }
    let(:note) { create :note, user: (create :user, name: "Someone Cool"), client: client }
    let(:user) { create :user, role: create(:organization_lead_role, organization: create(:organization)) }
    let(:user_who_assigned) { create :user, name: "Jia Tolentino" }
    let(:tax_return) { create :tax_return, year: 2020, client: client }
    before do
      login_as user
    end

    scenario "view notifications" do
      visit hub_user_notifications_path

      expect(page).to have_text("You've Been Assigned a Client")
      expect(page).to have_text("Jia Tolentino has assigned")
      expect(page).to have_link("Jenny Odell's")
      expect(page).to have_text("2020 return to you.")

      expect(page).to have_text("You've Been Tagged in a Note")
      expect(page).to have_text("Someone Cool has tagged you in Jenny Odell's notes.")
    end

    context "when the notifications reference archived clients" do
      let(:intake) { nil }
      let!(:archived_intake) {  create(:archived_2021_gyr_intake, client: client, preferred_name: "Jenny Odell") }

      it "still shows the data for the notification" do
        visit hub_user_notifications_path

        expect(page).to have_text("You've Been Assigned a Client")
        expect(page).to have_text("Jia Tolentino has assigned")
        expect(page).to have_link("Jenny Odell's")
        expect(page).to have_text("2020 return to you.")

        expect(page).to have_text("You've Been Tagged in a Note")
        expect(page).to have_text("Someone Cool has tagged you in Jenny Odell's notes.")
      end
    end
  end
end
