require "rails_helper"

RSpec.feature "Stimulus Triage Flow" do
  scenario "new client fills out stimulus triage" do
    # TODO: finish flow and connect with welcome page as epic work continues
    visit "/stimulus/filed-recently"
    expect(page).to have_selector("h1", text: "Have you already filed for 2018 and 2019?")
  end
end

