require "rails_helper"

RSpec.feature "client is not eligible for VITA services" do
  scenario "client checks one of the boxes on the eligibility page" do
    visit "/questions/feelings"
    expect(page).to have_selector("h1", text: "How are you feeling about your taxes?")
    choose "Happy face"
    click_on "Start my taxes online"

    expect(page).to have_selector("h1", text: "Our team is here to help!")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Let’s check a few things.")
    check "I earned money from owning a farm"
    click_on "Continue"

    expect(page).to have_selector("h1", text: "We’re unsure if you qualify for our services.")
  end
end
