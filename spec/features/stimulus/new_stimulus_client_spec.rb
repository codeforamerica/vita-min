require "rails_helper"

RSpec.feature "Stimulus Triage Flow" do
  scenario "new client fills out stimulus triage" do
    # TODO: finish flow and connect with welcome page as epic work continues
    visit "/stimulus/filed-recently"
    expect(page).to have_selector("h1", text: "Have you already filed for 2018 and 2019?")
    click_on("Yes")
    expect(page).to have_selector("h1", text: "Do you need to correct your 2019 taxes?")
    click_on("No")
    expect(page).to have_selector("h1", text: "Have you already filed for 2016 and 2017?")
    # click_on("Yes") # => /visit-stimulus-faq
    # click_on("No") # => /filing-might-help
  end

  scenario "new client has not filed this year" do
    visit "/stimulus/filed-recently"
    expect(page).to have_selector("h1", text: "Have you already filed for 2018 and 2019?")
    click_on("No")

    expect(page).to have_selector("h1", text: "Do you need to file this year?")
  end
end

