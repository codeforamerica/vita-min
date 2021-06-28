require "rails_helper"

RSpec.feature "CTC Intake", :js do
  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
  end

  scenario "new client entering ctc intake flow" do
    visit "/en/questions/overview"
    expect(page).to have_selector("h1", text: "Let's get started!")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "First, what's your name?")
    expect(page).to have_selector("p", text: "Welcome, we're excited to help you. We need some basic information to get started. We’ll start by asking what you like being called.")
    fill_in "Preferred first name", with: "Gary"
    click_on "Continue"

    intake = Intake.last
    expect(intake.preferred_name).to eq "Gary"
    expect(intake.timezone).not_to be_blank
  end
end