require "rails_helper"

RSpec.feature "Logging in to the Zendesk portal" do
  scenario "as a user that exists in Zendesk" do
    visit "/zendesk/sign-in"
    expect(page).to have_text "Sign in with Zendesk"
  end
end