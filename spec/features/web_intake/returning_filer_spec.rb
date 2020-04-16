require "rails_helper"

RSpec.feature "Returning user to online intake" do
  before do
    # sign in and consent, then sign out
    allow_any_instance_of(Users::SessionsController).to receive(:idme_request).and_return(
      user_idme_omniauth_callback_path(logout: "success")
    )
    visit "/questions/identity"
    click_on "Sign in with ID.me"

    expect(page).to have_selector("h1", text: "Great! Here's the legal stuff...")
    fill_in "Legal full name", with: "Gary Gnome"
    fill_in "Last 4 of SSN/ITIN", with: "1234"
    select "March", from: "Month"
    select "5", from: "Day"
    select "1971", from: "Year"
    click_on "I agree"

    OmniAuth.config.mock_auth[:idme] = :invalid_credentials
    silence_omniauth_logging do
      click_on "Sign out"
    end
  end

  # Failing until we remove ID.me flow that checks for consent on user model instead of intake
  xscenario "client tries to return to a sign in protected page after signing out" do
    silence_omniauth_logging do
      visit "/questions/wages"
    end
    expect(page).to have_selector("h1", text: "First, let’s get some basic information.")
    OmniAuth.config.mock_auth[:idme] = omniauth_idme_success
    click_on "Sign in with ID.me"

    expect(page).to have_selector("h1", text: "In 2019, did you receive wages or salary?")
  end
end
