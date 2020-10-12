require "rails_helper"

RSpec.feature "Visit home page" do
  scenario "has most critical content" do
    visit "/"
    expect(page).to have_text "Free tax filing, real human support."
    expect(page).to have_text "Sign up for next tax season now. We’ll notify you as soon as our service is back up in January!"
    expect(page).to have_link "Sign Up"
    click_on "Sign Up"
    expect(page).to have_text "sign up here"
  end

  context "in non-production environments" do
    before do
      allow(Rails.env).to receive(:production?).and_return(false)
    end

    scenario "it shows a sign in link" do
      visit "/"
      click_on "Volunteer sign in"
      expect(page).to have_text "Sign in"
    end
  end
end
