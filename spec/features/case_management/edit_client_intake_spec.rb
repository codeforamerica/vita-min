require "rails_helper"

RSpec.describe "a user editing a clients intake fields" do
  context "as a beta tester" do
    let(:user) { create :beta_tester }
    let(:client) { create :client, intake: create(:intake) }
    before { login_as user }

    scenario "I can update available fields" do
      visit edit_case_management_client_path(id: client.id)
      fill_in "Legal first name", with: "Colleen"
      fill_in "Legal last name", with: "Cauliflower"

      click_on "Save"
      expect(page).to have_text "Colleen Cauliflower"
    end
  end
end