require "rails_helper"

RSpec.feature "Web Intake New Client wants to file on their own" do
  scenario "a new client files through My Free Taxes" do
    visit "/questions/welcome"
    click_on "File taxes myself"

    expect(page).to have_selector("h1", text: "File your taxes yourself!")
    click_on "Continue through MyFreeTaxes"
    expect(current_url).to eq("https://www.myfreetaxes.com/en")
  end
end
