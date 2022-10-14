require "rails_helper"

RSpec.feature "Search for Users", :js do
  context "As an authenticated user" do
    let!(:noah_user) { create :organization_lead_user, name: "Noah Northfolk", email: "noah@example.com" }
    let!(:totoro_user) { create :organization_lead_user, name: "Totoro", email: "totoro@example.com" }
    let!(:mononoke_user) { create :greeter_user, name: "Princess Mononoke", email: "mononoke@example.com" }

    before do
      login_as create :admin_user
      visit hub_users_path
    end

    scenario "I can search for users by name", js: true do
      expect(page).to have_text "Users"
      expect(page).to have_text "Displaying all 4 entries"

      fill_in "search", with: "Noah"
      find('.hub-searchbar__button').click
      expect(page).to have_text "Displaying 1 entry"
      expect(page.all('.index-table__row')[1]).to have_text("Noah Northfolk")
    end

    scenario "I can search for users by email", js: true do
      fill_in "search", with: "mononoke@example.com"
      find('.hub-searchbar__button').click
      expect(page).to have_text "Displaying 1 entry"
      expect(page.all('.index-table__row')[1]).to have_text("Princess Mononoke")
    end

    scenario "I can search for users by user role", js: true do
      fill_in "search", with: "organization lead"
      find('.hub-searchbar__button').click
      expect(page).to have_text "Displaying all 2 entries"
      expect(page.all('.index-table__row')[1]).to have_text("Noah Northfolk")
      expect(page.all('.index-table__row')[2]).to have_text("Totoro")
    end
  end
end

