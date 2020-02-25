require "rails_helper"

RSpec.feature "Online intake user signs out" do
  before do
    allow_any_instance_of(Users::SessionsController).to receive(:idme_request).and_return(
      user_idme_omniauth_callback_path(logout: "success")
    )
  end

  scenario "client clicks the sign out button" do
    visit "/questions/identity"
    expect(page).to have_selector("h1", text: "Sign in")
    click_on "Sign in with ID.me"

    OmniAuth.config.mock_auth[:idme] = :invalid_credentials
    silence_omniauth_logging do
      click_on "Sign out"
    end

    expect(page).to have_selector("h1", text: "Free tax filing, real human support.")
    expect(page).to have_text "You've been successfully signed out."
  end
end