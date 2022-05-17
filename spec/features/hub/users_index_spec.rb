require "rails_helper"

RSpec.describe "a user viewing users" do
  context "as an authenticated user" do

    context "as an admin" do
      let(:current_user) { create :admin_user }
      let(:user_to_edit) { create :user }
      before do
        login_as current_user
        create :admin_user, name: "Martha Mango"
        create :admin_user, name: "Jerry Mango"
        create :admin_user, name: "Arthur Apple", email: "arthurapple@gmail.com"
      end

      scenario "i can narrow my search to specific users" do
        visit hub_users_path
        expect(page).to have_text "Displaying all 4 users"
        expect(page).to have_content "Martha Mango"
        expect(page).to have_content "Jerry Mango"
        expect(page).to have_content "Arthur Apple"

        fill_in "search", with: "Mango"
        click_on "Search"

        expect(page).to have_content "Martha Mango"
        expect(page).to have_content "Jerry Mango"
        expect(page).not_to have_content "Arthur Apple"

        fill_in "search", with: "martha mango"
        click_on "Search"

        expect(page).to have_content "Martha Mango"
        expect(page).not_to have_content "Jerry Mango"
        expect(page).not_to have_content "Arthur Apple"

        fill_in "search", with: "arthurapple@gmail.com"
        click_on "Search"
        expect(page).to have_content "Arthur Apple"
        expect(page).not_to have_content "Martha Mango"
        expect(page).not_to have_content "Jerry Mango"
      end
    end
  end
end