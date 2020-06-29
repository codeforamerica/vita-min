require "rails_helper"

RSpec.feature "Stimulus Triage Flow" do
  scenario "new stimulus triage client needs to correct" do
    # TODO: finish flow and connect with welcome page as epic work continues
    visit "/stimulus/filed-recently"
    expect(page).to have_selector("h1", text: "Have you already filed for 2018 and 2019?")
    click_on("Yes")
    expect(page).to have_selector("h1", text: "Do you need to correct your 2019 taxes?")
    click_on("Yes")
    expect(page).to have_selector("h1", text: "We’ll help you collect your stimulus check by filing!")
    click_on("Continue")
    expect(page).to have_selector("h1", text: "What years do you need to file for?")
  end

  scenario "new stimulus triage client needs to file" do
    # TODO: finish flow and connect with welcome page as epic work continues
    visit "/stimulus/filed-recently"
    expect(page).to have_selector("h1", text: "Have you already filed for 2018 and 2019?")
    click_on("No")
    expect(page).to have_selector("h1", text: "Do you need to file this year?")
    click_on("Yes")
    expect(page).to have_selector("h1", text: "We’ll help you collect your stimulus check by filing!")
    click_on("Continue")
    expect(page).to have_selector("h1", text: "What years do you need to file for?")
  end
end

