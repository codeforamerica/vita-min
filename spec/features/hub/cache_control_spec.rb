require "rails_helper"

RSpec.feature "Cache control", js: true do
  let(:user) { create :admin_user }

  before do
    login_as user
  end

  context "user on profile page, logs out and clicks back button", js: true do
    it "cache is cleared and redirects to the login page" do
      visit hub_user_profile_path
      page_change_check("My profile")
      click_link 'Sign out'

      page.evaluate_script('window.history.back()')
      sleep 0.1
      expect(page).to have_text "Sign in"
    end
  end

  context "user on client page, logs out and clicks back button", js: true do
    it "cache is cleared and redirects to the login page" do
      visit hub_clients_path
      sleep 0.1
      click_link 'Sign out'

      page.evaluate_script('window.history.back()')
      sleep 0.1
      expect(page).to have_text "Sign in"
    end
  end
end