require "rails_helper"

RSpec.feature "View user notifications" do
  context "As an authenticated user" do
    let!(:notification) { create :user_notification, read: false, created_at: DateTime.new(2021, 3, 15), user: user, notifiable: tax_return_assignment }
    let(:tax_return_assignment) { create :tax_return_assignment, tax_return: tax_return, assigner: user_who_assigned }
    let(:user) { create :user, role: create(:organization_lead_role, organization: create(:organization)) }
    let(:user_who_assigned) { create :user, name: "Jia Tolentino" }
    let(:tax_return) { create :tax_return, year: 2020, client: create(:client, intake: create(:intake, preferred_name: "Jenny Odell")) }
    before do
      login_as user
    end

    scenario "view notifications" do
      visit hub_notifications_path

      expect(page).to have_text("You've Been Assigned a Client")
      expect(page).to have_text("Jia Tolentino has assigned")
      expect(page).to have_link("Jenny Odell's")
      expect(page).to have_text("2020 return to you.")
    end
  end
end