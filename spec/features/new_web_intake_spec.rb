require "rails_helper"

RSpec.feature "Add a new intake case from the website" do
  scenario "new client" do
    visit "/questions/wages"
    expect(page).to have_selector("h1", text: "In 2019, did you receive wages or salary?")
    click_on "Yes"
    expect(page).to have_selector("h1", text: "In 2019, did you receive scholarships?")
    click_on "No"
  end
end
