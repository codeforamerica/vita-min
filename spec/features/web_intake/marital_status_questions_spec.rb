require "rails_helper"

RSpec.feature "Add a new intake case from the website" do
  scenario "new client has never been legally married" do
    visit "/questions/identity"
    expect(page).to have_selector("h1", text: "Sign in")
    click_on "Sign in with ID.me"
    # the ID.me flow would occur here. They should end up back on a success page.
    expect(page).to have_selector("h1", text: "Great! Here's our terms of service.")

    visit "/questions/ever-married"
    expect(page).to have_selector("h1", text: "Have you ever been legally married?")
    click_on "No"

    expect(page).to have_selector("h1", text: "Did you have any dependents in 2019?")
  end

  scenario "new client who answers yes to questions that require year input" do
    visit "/questions/identity"
    expect(page).to have_selector("h1", text: "Sign in")
    click_on "Sign in with ID.me"
    # the ID.me flow would occur here. They should end up back on a success page.
    expect(page).to have_selector("h1", text: "Great! Here's our terms of service.")

    visit "/questions/ever-married"
    expect(page).to have_selector("h1", text: "Have you ever been legally married?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "As of December 31, 2019, were you legally married?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "Did you live with your spouse during any part of the last six months of 2019?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "Are you legally separated?")
    click_on "Yes"

    select "2018", from: "What year was the separation finalized?"
    click_on "Next"

    expect(page).to have_selector("h1", text: "As of December 31, 2019, were you divorced?")
    click_on "Yes"

    select "2018", from: "What year was your divorce finalized?"
    click_on "Next"

    expect(page).to have_selector("h1", text: "As of December 31, 2019, were you widowed?")
    click_on "Yes"

    select "2018", from: "What was the year of your spouse's death?"
    click_on "Next"

    expect(page).to have_selector("h1", text: "Are you filing joint taxes with your spouse?")
  end

  scenario "new client who answers no to questions that require year input" do
    visit "/questions/identity"
    expect(page).to have_selector("h1", text: "Sign in")
    click_on "Sign in with ID.me"
    # the ID.me flow would occur here. They should end up back on a success page.
    expect(page).to have_selector("h1", text: "Great! Here's our terms of service.")

    visit "/questions/ever-married"
    expect(page).to have_selector("h1", text: "Have you ever been legally married?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "As of December 31, 2019, were you legally married?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "Did you live with your spouse during any part of the last six months of 2019?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "Are you legally separated?")
    click_on "No"

    expect(page).to have_selector("h1", text: "As of December 31, 2019, were you divorced?")
    click_on "No"

    expect(page).to have_selector("h1", text: "As of December 31, 2019, were you widowed?")
    click_on "No"

    expect(page).to have_selector("h1", text: "Are you filing joint taxes with your spouse?")
  end
end

