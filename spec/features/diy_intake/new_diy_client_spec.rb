require "rails_helper"

RSpec.feature "Web Intake New Client wants to file on their own" do
  scenario "new client wants to use FSA to file" do
    visit "/questions/welcome"
    expect(page).not_to have_selector("h2", text: "File taxes myself")
  end

  scenario "new client start DIY flow from dedicated DIY landing page" do
    visit "/diy"
    expect(current_path).to eq root_path
  end
end

