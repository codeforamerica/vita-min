require "rails_helper"

RSpec.feature "Search for Users" do
  context "As an authenticated user" do
    let!(:noah_user) { create :organization_lead_user, name: "Noah Northfolk", email: "noah@example.com" }
    let!(:totoro_user) { create :organization_lead_user, name: "Totoro", email: "totoro@example.com" }

    scenario "user can search for users by name" do
      login_as create :admin_user
      visit hub_users_path

      expect(page).to have_text "Users"
      expect(page).to have_text "Displaying all 3 entries"

      fill_in "search", with: "Noah"
      find('.hub-searchbar__button').click
      expect(page).to have_text "Displaying 1 entry"
      expect(page.all('.index-table__row')[1]).to have_text("Noah Northfolk")
    end
  end
end

