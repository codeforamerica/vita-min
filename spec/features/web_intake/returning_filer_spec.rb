require "rails_helper"

RSpec.feature "Returning user to online intake" do
  before do
    # sign in and consent, then sign out
    allow_any_instance_of(Users::SessionsController).to receive(:idme_request).and_return(
      user_idme_omniauth_callback_path(logout: "success")
    )
    visit "/questions/identity"
    click_on "Sign in with ID.me"
    check "I agree"
    click_on "Continue"

    OmniAuth.config.mock_auth[:idme] = :invalid_credentials
    silence_omniauth_logging do
      click_on "Sign out"
    end
  end

  scenario "client tries to return to a sign in protected page after being signed out" do
    silence_omniauth_logging do
      visit "/questions/wages"
    end
    expect(page).to have_selector("h1", text: "Sign in")
    OmniAuth.config.mock_auth[:idme] = omniauth_idme_success
    click_on "Sign in with ID.me"

    expect(page).to have_selector("h1", text: "What is your mailing address?")
  end
end
