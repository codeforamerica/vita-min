require "rails_helper"

RSpec.feature "client is not eligible for VITA services" do
  scenario "client checks one of the boxes on the eligibility page" do
    # Start in the questions flow
    visit "/en/questions/welcome"

    expect(page).to have_selector("h1", text: "Welcome! How can we help you?")
    click_on "File taxes with help"

    expect(current_path).to eq(file_with_help_questions_path)
    click_on "Continue"

    expect(page).to have_selector("h1", text: "What years do you need to file for?")
    check "2017"
    check "2019"
    click_on "Continue"

    #Non-production environment warning
    expect(page).to have_selector("h1", text: "Thanks for visiting the GetYourRefund demo application!")
    click_on "Continue to example"

    expect(page).to have_selector("h1", text: "Let's get started")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Let’s check a few things.")
    check "I earned money from owning a farm"
    click_on "Continue"

    expect(page).to have_selector("h1", text: "We’re unsure if you qualify for our services.")
  end
end
