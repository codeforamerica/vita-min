require "rails_helper"

RSpec.feature "Visit home page" do
  scenario "has most critical content" do
    visit "/"
    expect(page).to have_text "Free tax filing, real human support."
    expect(page).to have_text "Maximize your refund by filing with our trusted volunteers."
    expect(page).to have_link "Get started"
  end
end