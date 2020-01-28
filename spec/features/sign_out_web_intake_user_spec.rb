require "rails_helper"

RSpec.feature "Online intake user signs out" do
  scenario "client clicks the sign out button" do
    visit "/questions/identity"
    expect(page).to have_selector("h1", text: "Sign in")
    click_on "Sign in with ID.me"

    click_on "Sign out"
    expect(page).to have_selector("h1", text: "Free tax help from IRS-certified volunteers.")
    expect(page).to have_text "You've been successfully signed out."
  end
end