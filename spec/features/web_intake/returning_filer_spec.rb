require "rails_helper"

RSpec.feature "Returning user to online intake" do
  scenario "client tries to return to a sign in protected page after being signed out" do
    visit "/questions/wages"
    expect(page).to have_selector("h1", text: "Sign in")
    click_on "Sign in with ID.me"

    expect(page).to have_selector("h1", text: "Great! Here's our terms of service.")
  end
end
