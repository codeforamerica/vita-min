require "rails_helper"

RSpec.feature "Add a new intake case from the website" do
  scenario "new client who was divorced and widowed" do
    visit "/questions/identity"
    expect(page).to have_selector("h1", text: "Sign in")
    click_on "Sign in with ID.me"

    # the ID.me flow would occur here. They should end up back on a success page.
    expect(page).to have_selector("h1", text: "Welcome Gary!")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "As of December 31, 2019, were you legally married?")
    click_on "No"

    expect(page).to have_selector("h1", text: "As of December 31, 2019, were you divorced?")
    click_on "Yes"

    select "2018", from: "What year was your divorce finalized?"
    click_on "Next"

    expect(page).to have_selector("h1", text: "As of December 31, 2019, were you widowed?")
    click_on "Yes"

    select "2018", from: "What was the year of your spouse's death?"
    click_on "Next"
  end
end

