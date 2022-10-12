require "rails_helper"

RSpec.feature "Search for Users", :js do
  context "As an authenticated user" do
    let(:user) { create :organization_lead_user, name: "Noah", email: "noah@example.com" }

    before do
      login_as user
    end

    scenario "I can search for users by name, role and email", js: true do
      visit hub_users_path

      expect(page).to have_text "Users"

      #expect table of users here

      # search for client
      fill_in "Search", with: "Noah"
      click_button #how to say click the search icon
      expect(page.all('.client-row').length).to eq 1
      expect(page.all('.client-row')[0]).to have_text() #test for the name noah here

      end
  end
end

