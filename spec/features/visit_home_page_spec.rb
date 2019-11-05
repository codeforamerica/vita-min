require "rails_helper"

RSpec.feature "Visit home page" do
  scenario "default visit" do
    visit "/"
    expect(page).to have_text "Find VITA help near you!"
  end
end