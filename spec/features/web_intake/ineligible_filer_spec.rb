require "rails_helper"

RSpec.feature "client is not eligible for VITA services" do
  scenario "client checks one of the boxes on the eligibility page" do
    visit "/questions/feelings"
    expect(page).to have_selector("h1", text: "How are you feeling about your taxes?")
    choose "Happy face"
    click_on "Start my taxes online"

    expect(current_path).to eq(file_with_help_questions_path)
    click_on "Continue"

    # Already Filed? Page
    expect(current_path).to eq(already_filed_questions_path)
    click_on "Yes"

    expect(page).to have_selector("h1", text: "What years do you need to file for?")
    check "2017"
    check "2019"
    click_on "Continue"
    expect(page).to have_selector("h1", text: "Let's get started")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Let’s check a few things.")
    check "I earned money from owning a farm"
    click_on "Continue"

    expect(page).to have_selector("h1", text: "We’re unsure if you qualify for our services.")
  end
end
