require "rails_helper"

RSpec.feature "A new intake case from the website fails to authenticate with ID.me" do
  before do
    OmniAuth.config.mock_auth[:idme] = :access_denied
  end

  scenario "client decides to authenticate again" do
    visit "/questions/identity"
    expect(page).to have_selector("h1", text: "Sign in")
    silence_omniauth_logging do
      click_on "Sign in with ID.me"
    end
    # the ID.me flow would occur here. They should end up on the offboarding page.
    expect(page).to have_selector("h1", text: "Oh no! We hate to see you go...")

    OmniAuth.config.mock_auth[:idme] = omniauth_idme_success
    click_on "Return to ID.me"

    expect(page).to have_selector("h1", text: "Great! Here's the legal stuff...")
  end

  scenario "client decides to find other options" do
    visit "/questions/identity"
    expect(page).to have_selector("h1", text: "Sign in")
    silence_omniauth_logging do
      click_on "Sign in with ID.me"
    end

    # the ID.me flow would occur here. They should end up on the offboarding page.
    expect(page).to have_selector("h1", text: "Oh no! We hate to see you go...")
    click_on "Find other options"

    expect(page).to have_selector("h1", text: "Let's find a way to help you!")
    expect(page).to have_link("Visit MyFreeTaxes.com", href: "https://www.myfreetaxes.com")
    click_on "Find a VITA site near you"

    expect(page).to have_text "Enter your zip code to find providers near you"
  end
end
