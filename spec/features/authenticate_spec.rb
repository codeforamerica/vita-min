require "rails_helper"

RSpec.feature "Logging in and out to the volunteer portal" do
  # Making these users admins because profile page is admin only for now
  let!(:user) { create(:user, name: "German Geranium", email: "german@flowers.orange", password: "goodPassword", role: "admin") }

  scenario "logging in and out" do

    # go to password-based sign in page
    visit new_user_session_path

    expect(page).to have_text "Sign in"
    fill_in "Email", with: "german@flowers.orange"
    fill_in "Password", with: "goodPassword"
    click_on "Sign in"

    # Expect to be redirected to user profile page
    expect(page).to have_text "German Geranium"
    expect(page).to have_text "Admin"

    click_on "Sign out"
    # Should be redirected to home page
    expect(page).to have_text "You've been successfully signed out."
    expect(page).to have_text "Free tax filing, real human support"
  end

  scenario "getting locked out due to using the wrong password a lot" do
    # go to password-based sign in page
    visit new_user_session_path

    user.update(failed_attempts: 4)
    expect do
      expect(page).to have_text "Sign in"
      fill_in "Email", with: "german@flowers.orange"
      fill_in "Password", with: "wrongPassword"
      click_on "Sign in"
      expect(page).to have_text "Incorrect email or password. After 5 login attempts, accounts are locked for 30 minutes."
    end.to change { user.reload.failed_attempts }.by(1).and change { user.reload.locked_at.present? }.from(false).to(true)

    # Move locked-at to be 31 minutes ago, since the lockout duration is 30 minutes
    user.update(locked_at: 31.minutes.ago)
    visit new_user_session_path
    fill_in "Email", with: "german@flowers.orange"
    fill_in "Password", with: "goodPassword"
    click_on "Sign in"
    # Expect to be redirected to user profile page
    expect(page).to have_text "German Geranium"
    expect(page).to have_text "Admin"
  end
end
