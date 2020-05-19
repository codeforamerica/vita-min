require "rails_helper"

RSpec.feature "Web Intake New Client wants to file on their own" do
  scenario "new client wants to use FSA to file" do
    visit "/diy/file-yourself"

    expect(page).to have_selector("h1", text: "File your taxes yourself!")

    # TODO: continue button doesn't go anywhere yet
  end

  scenario "new client thinks they want DIY but changes their mind" do
    visit "/diy/file-yourself"

    expect(page).to have_selector("h1", text: "File your taxes yourself!")
    click_on "Actually, I need assistance filing"

    expect(page).to have_selector("h1", text: "File with the help of a tax expert!")
  end
end

