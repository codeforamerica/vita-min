require "rails_helper"

RSpec.feature "Visit home page" do
  scenario "has most critical content" do
    visit "/"
    expect(page).to have_text "Free tax help from IRS-certified volunteers."
    expect(page).to have_text "Find a local VITA site near you and get more of your refund dollars back by filing for free"
    expect(page).to have_link "Find a location"
  end
end